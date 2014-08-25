$(function () {
  var today = new Date();
  /* courses#(new|edit) */
  if (window.location.href.match(/courses\/(\d+\/)?(new|edit)(?:\?.+)?/)){
    /* Sets a particular requested date as actual date */
    $('body').on('click', 'button.date-setter', function (e) {
      e.preventDefault();

      $(this).closest('.section').find('input.actual-date').val($(this).prev().find('input').val());
    });

    /* Add sessions to form */
    $('body').on('click', 'button.add_session', function (e) {
      e.preventDefault();

      // Make SURE it can't end up with the same number
      var index = +$('.session').last().attr('class').match(/session-(\d+)/)[1] + 1;
      var section_index = +$('.section').last().attr('class').match(/section-(\d+)/)[1] + 1;

      $.get('/courses/session_block',
            {index: index,
             section_index: section_index})
        .done(function (data, status, jqXHR) {
          $('.sessions').append(data);
          $(e.currentTarget).trigger('blur')
          $('.section').last().find('.requested_date').first().trigger('focus');
        });
    });

    /* Add sections to session in form */
    $('body').on('click', 'button.add_section', function (e) {
      e.preventDefault();

      var $this_session = $(e.currentTarget).closest('.session');
      var session_i = +$this_session.find('.session_val').val();
      var section_index = 1 + +$('.section').last().attr('class').match(/section-(\d+)/)[1];

      $this_session.find('.section-header').removeClass('hidden');

      $.get('/courses/section_block', {session_i: session_i, section_index:section_index})
        .done(function (data) {
          $(e.currentTarget).before(data);
          $(e.currentTarget).trigger('blur');
          $this_session.find('.section').last().find('.requested_date').first().trigger('focus');
        });
    });

    /* Delete sections, either by adding _destroy input (for sections in DB) *
     *   or by deleting section from the page if not.                        *
     * If this is the last section in a session, and that session is not the *
     *   last section on the page, delete that.                    */
    $('body').on('click', '.section:not(.deleted) button.delete_section', function (e) {
      e.preventDefault();

      var $this_session = $(e.currentTarget).closest('.session');
      var $section = $(e.currentTarget).closest('.section');

      var persisted = $section.find('.id_val').length;
      var num_sections = $this_session.find('.section').length;
      var name;

      if (persisted) {
        name = $section.find('input.id_val').attr('name').replace(/\[id\]$/, '[_destroy]');
        $section.addClass('deleted');
        $section.find('button.delete_section').removeClass('glyphicon-minus').addClass('glyphicon-plus');
        $section.append('<input type="hidden" class="destroy" name="' + name + '" value="1">');
      }
      else {
        $section.remove();
        if (num_sections == 1) {
          $this_session.remove();
        }
        else if (num_sections == 2) {
          $this_session.find('.section-header').addClass('hidden');
        }
      }
    });

    /* Undelete section */
    $('body').on('click', '.section.deleted button.delete_section', function (e) {
      e.preventDefault();

      var $section = $(e.currentTarget).closest('.section');

      $section.find('input.destroy').remove();
      $section.removeClass('deleted');
      $section.find('button.delete_section').removeClass('glyphicon-plus').addClass('glyphicon-minus');
    });


    /* Prompt user for submission if both backdated and post-dated actual_dates exist, *
     *   deletions excepted.                                                           */
    $('body').on('submit', 'form.formtastic.course', function (e) {
      var backdated = []; var postdated = [];
      var confstring = "You have actual dates in both the past and future, is this correct?\n\n";

      /* We need the datetimepickers definitely set up, so we can call the API function on them */
      $('.actual-date:not(.hasDatepicker)').each(function (i, el) { crt.setup_datetimepicker(el) });

      $('.datetime_picker .actual-date')
        .filter(function (i,el) { return $(el).parents('.deleted').length == 0})
        .each(function (i,el) {
          var date = $(el).datetimepicker('getDate');

          if (date < today) {
            backdated.push(date.toString());
          }
          else {
            postdated.push(date.toString());
          }
        });

      if (backdated.length > 0 && postdated.length > 0) {
        confstring += "Past Dates:\n\t" + backdated.join("\n\t") + "\n\n";
        confstring += "Future Dates:\n\t" + postdated.join("\n\t") + "\n";
        if (!confirm(confstring)) {
          e.preventDefault();
        }
      }
    });
  }
});
