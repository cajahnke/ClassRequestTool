# Since we don't need to persist the reports, we don't inherit from ActiveRecord::Base
class Report

  attr_accessor :report_filters
  
  # Builds the filter
  def build_filters(params)
    @report_filters = {
      :clauses => [],
      :displays => []
    }
    if params[:closed_only]
      @report_filters[:clauses] << "status='Closed'"
      @report_filters[:displays] << "Only closed classes"
    else
      @report_filters[:clauses] << "status!='Cancelled'"
      @report_filters[:displays] << "Active and closed classes (all except cancelled)"
   end
    
    unless params[:repo].blank?
      repo = Repository.find(params[:repo].to_i)
      @report_filters[:clauses] << "repository_id=#{params[:repo]}"
      @report_filters[:displays] << "For #{repo.name} only"    
    end
    
    unless params[:affiliate].blank?
      @report_filters[:clauses] << "affiliation='#{params[:affiliate]}'"
      @report_filters[:displays] << "Requests from #{params[:affiliate]} only"
    end
    
    unless params[:start_date].blank? || params[:end_date].blank?
      start_date = to_time_format(params[:start_date])
      end_date = to_time_format(params[:end_date])
      unless end_date.to_time < start_date.to_time
        @report_filters[:clauses] << "created_at <@ tsrange('#{start_date}','#{end_date}')"
        @report_filters[:displays] << "Request created between <b>#{params[:start_date]}</b> and <b>#{params[:end_date]}</b>"
      end    
    end
    @report_filters
  end
  
  # The params specify what data to include
  def stats(params)
    output = {}
    params[:selected_reports].keys.each do |report|
      report = report.to_sym
      options = Rails.configuration.crt_reports[report]
      if 'stat' == options['type']
        where_clause = @report_filters[:clauses].clone
        unless options['where'].blank?
          where_clause << options['where']
        end
        sql = "#{options['select']} WHERE #{where_clause.join(' AND ')} #{options['group_by']} #{options['order_by']} #{options['limit']}"
        result = do_query(sql)
        output[report] = []
        result.each do |row|
          output[report] << row
        end
      elsif 'graph' == options['type']
        output[report] = 'Loading via AJAX'
      end
    end
    output
  end
  
  def graph(params)
    graph = Rails.configuration.crt_reports[params[:id].to_sym]
    where_clause = @report_filters[:clauses].clone
    output = {}
    output['id'] = params[:id]
    output['options'] = graph['highchart_options']
    sql = "#{graph['select']} WHERE #{where_clause.join(' AND ')} #{graph['group_by']} #{graph['order_by']} #{graph['limit']}"
    result = do_query(sql)
    if graph['data_model']['xAxis'] && graph['data_model']['xAxis']['categories']
      cat = true
      cat_keys = graph['data_model']['xAxis']['categories'].split(',')
      output['options']['xAxis']['categories'] = []
    end
    if graph['data_model']['series'] && graph['data_model']['series']['data']
      series = true
      ser_keys = graph['data_model']['series']['data'].split(',')
      output['options']['series'] = [{ 'data' => [] }]
    end
    result.each do |row|
      if cat
        output['options']['xAxis']['categories'] << cat_keys.map { |k| row[k] }[0]
      end
      if series
        point = ser_keys.length == 1 ? row[ser_keys.first].to_i : ser_keys.map { |k| row[k].to_i }
        output['options']['series'][0]['data'] << point
      end
    end
    output
  end
  
  def do_query(sql)
    connection = ActiveRecord::Base.connection
    result = connection.execute( sql )
    connection.close
    result
  end
    
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end

  def persisted?
    false
  end
  
private
  def to_time_format(string)
    unless /\d{1,2}\/\d{1,2}\/\d{2,4}/.match(string)
      raise 'Format of the string must be ##/##/####'
      return
    end
    x = string.split('/')
    "#{x[2]}-#{x[0]}-#{x[1]}"
  end
end
