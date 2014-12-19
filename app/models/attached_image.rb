class AttachedImage < ActiveRecord::Base

  attr_accessible :picture_id, :picture_type, :image, :image_cache, :caption
  mount_uploader :image, ImageUploader
  
  belongs_to :picture, polymorphic: true

#  validates_presence_of :image, :message => "requires an image!"
  validates_length_of :caption, :maximum => 255
  
  # Convenience method for jquery file upload
  def to_jq_upload
    {
      "name" => read_attribute(:image),
      "size" => image.size,
      "url" => image.url,
      "thumbnail_url" => image.thumb.url,
      "delete_url" => attached_image_path(:id => id),
      "delete_type" => "DELETE"
    }
  end
end
