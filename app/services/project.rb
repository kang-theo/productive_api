class Project
  attr_accessor :id,
                :type,
                :attributes 
  
  # belongs_to :people
  # belongs_to :workflow
  # belongs_to :organization
  # has_many :member_ships

# {"id": 1, "type": "testc", "attributes": { "name": "test project", "number": "1", "project_number": "1", "project_type_id": "2", "project_color_id": "null", "last_activity_at": "2023-10-23T06:10:48.000+02:00", "public_access": true, "time_on_tasks": true, "tag_colors": {}, "archived_at": "null", "created_at": "2023-10-23T06:10:48.107+02:00", "template": false, "budget_closing_date": "null", "needs_invoicing": false, "custom_fields": "null", "task_custom_fields_ids": "null", "sample_data": false }}
  def initialize(data)
    @data = data
    @attrs = Hash.new()
    
    json_data = JSON.parse(ActiveSupport::JSON.encode(@data))
    project_attrs = ProjectAttr.new(json_data["attributes"])
    attr_keys = project_attrs.keys

    attr_keys.each do |key|
      @attrs[key] = project_attrs.send(key)
    end

    create_accessors
  end

  # create accessors dynamically for project and its attributes
  def create_accessors
    if @data.blank? && @attrs.blank?
      raise "Invalid attributes." 
    end

    create_accessors_for_hash(@attrs)
    create_accessors_for_hash(@data)
  end

  def create_accessors_for_hash(hash)
    hash.each do |key, value|
      puts key
      if value.is_a?(Hash) 
        return
      end

      class_eval do
        define_method(key) do
          value
        end

        define_method("#{key}=") do |new_value|
          hash[key] = new_value
        end
      end
    end
  end

#   def company
#     # Company.find
#   end

#   def self.find_all_by_company(company_id)
    
#     data.each do |item|
#       if item.relationships.company.data.id ===company_id
#     end
#   end

#   def workflow
# end

#   def organization

#   end

#   def project_manager(id)
#     People.find(id)
#   end

#   def member_ships

#   end
end