require 'spec_helper'

describe 'articles/show' do
  before(:each) do
    @user = stub_model(User, display_name: 'Thomas')
    @author = @user
    @article =  stub_model(Article,
                           :title => "Ruby article",
                           :content => "My Ruby content",
                           :tag_list => ["Ruby", "Rails"],
                           :user => @user,
                           :created_at => Time.now,
                           :updated_at => Time.now)
# Create a voting history 1 up, 2 down
    @upvotes = [stub_model(ActsAsVotable::Vote)]
    @downvotes = [stub_model(ActsAsVotable::Vote),stub_model(ActsAsVotable::Vote)]
    @article.stub(:upvotes => @upvotes,
                  :downvotes => @downvotes )
  end

  context 'user is not signed in' do
    before :each do
      view.stub(:user_signed_in?).and_return(false)
    end

    it 'should show article content' do
      render
      rendered.should have_css('div#doc-box')
      rendered.should have_text(@article.title)
      rendered.should have_content("Created on #{@article.created_at.strftime('%d %B %y')}")
      rendered.should have_content("Last updated #{time_ago_in_words(@article.updated_at)}")
      rendered.should have_text(@article.tag_list.join(', '))
      rendered.should_not have_link('edit article')
    end

    it 'should show article vote value' do
        render
        rendered.should have_content("Vote value: #{@article.upvotes.size-@article.downvotes.size}")
        rendered.should_not have_link('Vote up')
        rendered.should_not have_link('Vote down')
    end

  end

  context 'user is signed in' do
    before :each do
      view.stub(:user_signed_in?).and_return(true)
      assign(:current_user, @user)
    end

    it 'renders a edit button' do
      render
      rendered.should have_link('edit article')
    end

    it 'renders the vote value and links' do
      render
      rendered.should have_link('Vote up')
      rendered.should have_link('Vote down')
      rendered.should have_content("Vote value: #{@article.upvotes.size-@article.downvotes.size}")
    end

  end

end
