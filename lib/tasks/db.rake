class DbTasks
  include Rake::DSL

  def initialize
    namespace :db do
      desc 'Init Category and Subcategory'
      task init_category_and_subcategory: :environment do
        json_data = File.read(data_folder.join('category_data.json'))
        category_data = JSON.parse(json_data)

        category_data.each do |value|
          Category.find_or_create_by!(name: value['name']).tap do |category|
            value['subcategories_attributes'].each do |subcat|
              category.subcategories.find_or_create_by!(name: subcat['name'])
            end
          end
        end
      end
    end
  end
end

def data_folder
  Rails.root.join('lib/tasks/data')
end

DbTasks.new
