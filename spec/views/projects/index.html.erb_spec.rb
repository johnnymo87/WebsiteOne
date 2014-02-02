require 'spec_helper'

describe 'projects/index.html.erb' do
  let(:projects_collection) { (1..5).map {|id|
    stub_model(Project, {
        id: id,
        title: 'hello',
        description: 'world',
        status: 'one',
        created_at: '2014-01-23 23:39:15'
    }) } }
  before(:each) do
    projects_collection.stub(:total_pages).and_return(2)
    projects_collection.stub(:current_page).and_return(1)
    assign(:projects, projects_collection)
  end

  context 'pagination' do
    it 'should render previous, next, and page numbers' do
      render
      rendered.should have_content 'Previous 1 2 Next'
    end
  end

  context 'for signed in and not signed in users' do
    it 'should display table with columns' do
      render

      rendered.should have_css('table#projects')
      rendered.should have_css('h1', :text => 'List of Projects')
    end

    it 'should display content' do
      render
      rendered.within('table#projects tbody') do |table_row|
        table_row.should have_content 'Created:'
        table_row.should have_content 'Status:'
      end
    end

    it 'should render a link' do
      render
      project = projects_collection.first
      rendered.within('table#projects tbody') do |table_row|
        expect(table_row).to have_link(project.title, href: project_path(project.id))
      end
    end

  end

  context 'user signed in' do
    before :each do
      view.stub(:user_signed_in?).and_return(true)
    end

    it 'should render a create new project button' do
      render
      rendered.should have_link('New Project', :href => new_project_path)
    end

    it 'should render a link Edit' do
      render
      #TODO Y refactor to a smarter traversing
      i = 0
      rendered.within('table#projects tbody') do |table_row|
        i += 1
        expect(table_row).to have_link('Edit', href: edit_project_path(i))
      end
    end
  end

  context 'user not signed in' do
    before :each do
      view.stub(:user_signed_in?).and_return(false)
    end

    it 'should not render a create new project button' do
      render
      expect(rendered).not_to have_link('New Project', :href => new_project_path)
    end

    it 'should not render a link Edit' do
      render
      #TODO Y refactor to a smarter traversing
      i = 0
      rendered.within('table#projects tbody') do |table_row|
        i += 1
        expect(table_row).not_to have_link('Edit', href: edit_project_path(i))
      end
    end
  end

  describe 'content formatting' do
    it 'renders format in short style' do
      render
      rendered.within('table tr#1 td[1]') do |rendered_date|
        correct_date = projects_collection.first.created_at.strftime("%Y-%m-%d")
        expect(rendered_date.text).to contain(correct_date)
      end
    end
  end
end
