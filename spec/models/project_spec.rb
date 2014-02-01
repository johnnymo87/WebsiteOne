require 'spec_helper'

#TODO set constraint: unique titles?
describe Project do
  context '#save' do
    before do
      @project = stub_model(Project, title: 'Title', description: 'Description', status: 'Status')
    end
    let(:project) { @project }
    context 'returns false on invalid inputs' do
      it 'blank Title' do
        project.title = ''
        expect(project.save).to be_false
      end
      it 'blank Description' do
        project.description = ''
        expect(project.save).to be_false
      end
      it 'blank Status' do
        project.status = ''
        expect(project.save).to be_false
      end
    end
  end
end

describe '#paginate' do
  before(:all) { 9.times { FactoryGirl.create(:project) } }
  after(:all)  { User.delete_all }

  it 'returns paginated values' do
    Project.paginate(page: 1).should eq Project.first 5
    Project.paginate(page: 1).length.should eq 5
    Project.paginate(page: 2).length.should eq 4
    Project.paginate(page: 1).count.should eq 9
  end
end
