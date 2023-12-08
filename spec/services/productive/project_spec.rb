require 'rails_helper'
require 'yaml'
require 'httparty'

RSpec.describe Productive::Project, type: :model do
# =begin
  describe '#initialize' do
    context 'instantiate a project for creating a new project' do
      # TODO: using FactoryBot to create a project
      let(:attributes){ {name: 'Create project x', project_type_id: 1, project_manager_id: '561888', company_id: '699400', workflow_id: '32544'} }
      let(:association_info){ {'project_manager' => '561888', 'company' => '699400', 'workflow' => '32544'} }

      it 'creates an instance with default attributes' do
        entity = Productive::Project.new
        # getter(create_accessors) and default value
        expect(entity.name).to eq('')
        expect(entity.project_type_id).to be_nil
        expect(entity.project_manager_id).to eq('')
        expect(entity.company_id).to eq('')
        expect(entity.workflow_id).to eq('')
      end

      it 'creates instance with provided attributes' do
        entity = Productive::Project.new(attributes)
        #create_accessors - getter
        expect(entity.name).to eq('Create project x')
        expect(entity.project_type_id).to eq(1)
        expect(entity.project_manager_id).to eq('561888')
        expect(entity.company_id).to eq('699400')
        expect(entity.workflow_id).to eq('32544')

        # setter
        entity.project_type_id = 2
        entity.project_manager_id = '561890'
        expect(entity.project_type_id).to eq(2)
        expect(entity.project_manager_id).to eq('561890')  
      end

      #define_associations
      it 'defines associations' do
        entity = Productive::Project.new(attributes, association_info) 

        expect(entity).to respond_to(:project_manager)
        expect(entity).to respond_to(:company)
        expect(entity).to respond_to(:workflow)
      end
    end

    # TODO: to be tested after mocking response
    # context 'instantiate a project based on info from the API response' do
    #   it 'creates an instance with default attributes' do
    #     entity = Productive::Project.new
    #     expect(entity.name).to eq('')
    #     expect(entity.project_type_id).to be_nil
    #     # ... other default attributes
    #   end

    #   it 'creates instance with provided attributes' do
    #     attributes = { name: 'Project X', project_type_id: 1, project_manager_id: '123' }
    #     entity = Productive::Project.new(attributes)
    #     expect(entity.name).to eq('Project X')
    #     expect(entity.project_type_id).to eq(1)
    #     expect(entity.project_manager_id).to eq('123')
    #   end
    # end
  end

  describe '.all' do
    it 'sends a GET request for all entities' do
      # Mock:
      # 1. [mock] get data as return value
      all_projects = File.read('./spec/fixtures/all_projects.yaml')
      data = OpenStruct.new(YAML.safe_load(all_projects))

      # 2. [stub] intercept requests and return specified fake data; all methods that will be called by .all need to be stubbed
      # stub the HTTParty.get method to return a fake response
      allow(Productive::HttpClient).to receive(:get).and_return(data.body)

      # 3. [mock] for non-active-record model, use build_list instaead of create_list
      projects = FactoryBot.build_list(:project, 5)
      # 4. [stub] stub the handle_response method to return a specific result
      allow(Productive::Parser).to receive(:handle_response).and_return(projects)
      # expect(Productive::Parser).to receive(:handle_response).with(data.body, Productive::Project)

      # Act
      # 5. call the method, when methods above are called, they will be intercepted
      entities = Productive::Project.all
      entity = entities.first

      # Assert
      expect(entity).to be_an_instance_of(Productive::Project)
    end
  end

  describe '.find' do
    it 'sends a GET request for a specific entity with valid id' do
      # Mock
      # just stub it
      allow(Productive::HttpClient).to receive(:get).and_return(nil)

      project = FactoryBot.build_list(:project, 1)
      allow(Productive::Parser).to receive(:handle_response).and_return(project)

      # Act
      entity = Productive::Project.find("any_id")

      # Assert
      expect(entity).to be_an_instance_of(Productive::Project)
    end

    it 'sends a GET request for a specific entity with invalid id' do
      # mock
      # not_found = File.read('./spec/fixtures/404_not_found.json')
      # data = OpenStruct.new(JSON.parse(not_found))
      # allow(Productive::HttpClient).to receive(:get).and_return(data.body)
      allow(Productive::HttpClient).to receive(:get).and_return(nil)

      allow(Productive::Parser).to receive(:handle_response).and_return([])

      entity = Productive::Project.find(-1)
      expect(entity).to be_nil
    end
  end

  describe '#save' do
    context 'POST request with valid attributes' do
      it 'creates a new entity' do
        # arrange
        entity = Productive::Project.new
        entity.name = 'New project'
        entity.project_type_id = 1
        entity.project_manager_id = '561888'
        entity.company_id = '699398'
        entity.workflow_id = '32544'

        # stub
        one_project = File.read('./spec/fixtures/create_project.yaml')
        response = OpenStruct.new(YAML.safe_load(one_project))

        allow(Productive::HttpClient).to receive(:post).and_return(response)
        allow(Productive::HttpClient).to receive(:patch).and_return(response)

        # act
        result = entity.save

        debugger
        # assert
        expect(result.id).to eq("399787")
        expect(result.name).to eq("New project")
        expect(result.company_id).to eq("699398")
      end

      it 'updates an existing entity' do
        # arrange
        entity = Productive::Project.find(399787)
        entity.name = 'Update project'
        entity.project_type_id = 1
        entity.project_manager_id = '561888'
        entity.company_id = '699398'
        entity.workflow_id = '32544'

        # stub
        one_project = File.read('./spec/fixtures/update_project.yaml')
        response = OpenStruct.new(YAML.safe_load(one_project))

        allow(Productive::HttpClient).to receive(:post).and_return(response)
        allow(Productive::HttpClient).to receive(:patch).and_return(response)

        # act
        result = entity.save

        # assert
        expect(result.id).to eq("399787")
        expect(result.name).to eq("Update project")
        expect(result.project_manager_id ).to eq("561888")
      end

      it 'updates an non-existing entity' do
        allow(Productive::HttpClient).to receive(:patch).and_return(nil)
        allow(Productive::Parser).to receive(:handle_response).and_return([])

        entity = Productive::Project.find(-1)
        expect(entity).to be_nil
      end
    end

    context 'POST request with invalid attributes, lacking required params' do
      it 'creates a new entity with some required attributes missing' do
        # arrange
        entity = Productive::Project.new
        entity.name = 'New project'
        entity.project_manager_id = '561888'

        # mock: try to mock a HTTParty::Response
        # mocked_response = HTTParty::Response.new(
        #   # code: 200,
        #   # parsed_response: 
        # {
        #   "data": {
        #     "id": 399787,
        #     "type": "projects",
        #     "attributes": {
        #       "name": "Update project",
        #       "number": 1,
        #       "project_number": 1,
        #       "project_type_id": 1,
        #       "project_color_id": 9
        #     },
        #     "relationships": {
        #       "organization": {
        #         "data": {
        #           "type": "organizations",
        #           "id": 31810
        #         }
        #       },
        #       "workflow": {
        #         "data": {
        #           "type": "workflows",
        #           "id": 32544
        #         }
        #       },
        #       "memberships": {
        #         "data": {
        #           "type": "memberships",
        #           "id": 6368022
        #         }
        #       }
        #     }
        #   }
        # }
          #   # parsed_response: {"data":{"id":"399787","type":"projects","attributes":{"name":"Update project"}}}
          #   HTTParty::Request.new(Net::HTTP::Get, '/'), # request object
          #   OpenStruct.new(body: '{"data": {"id": "123", "type": "projects"}}'), # response object
          #   lambda { 'raw_response' }, # response block
          #   200 # status code
          # )
          # allow(Productive::HttpClient).to receive(:post).and_return(mocked_response)
          # expect(Productive::HttpClient).to receive(:post).with('projects', instance_of(String))

          # act
          result = entity.save

        # assert
        expect(result).to be_nil
      end

      it 'updates an existing entity without changing anything' do
        # arrange
        entity = Productive::Project.find(399787)
        entity.name = 'Update project'
        entity.company_id = '699400'

        # assert
        expect{entity.save}.to raise_error(ApiRequestError, 'Attributes are blank.')
      end
    end
  end

  describe '#inspect' do
    it 'outputs a string representation of an object' do
      entity = Productive::Project.new
      entity.name = "New name"
      entity.company_id = "699401"  

      expect(entity.inspect).not_to include("changed_attrs")
      expect(entity.inspect).not_to include("changed_relationships")
    end
  end

  describe "#archive" do
    it "archives an existing project" do
      entity = Productive::Project.find(399787)  
      result = entity.archive
      expect(result.archived_at).to_not be_nil 
    end

    it "archives an non-existing project" do
      entity = Productive::Project.find(-1)  
      expect(entity).to be_nil 
    end
  end

  describe "#restore" do
    it "restores an existing project" do
      entity = Productive::Project.find(399787)  
      result = entity.restore
      expect(result.archived_at).to be_nil 
    end
  end

  # TODO: to be tested after mocking the response
  # describe "#destory" do
  #   it "deletes an existing project" do
  #     entity = Productive::Project.find(399787)  
  #     result = entity.destroy
  #     expect(result).to be_nil 
  #   end
  # end

  # describe ".copy" do
  #   it "replicates an existing project" do
  #     entity = Productive::Project.find(399787)  
  #     result = entity.copy
  #     expect(result).to be_an_instance_of(Productive::Project)
  #   end
  # end
# =end
end