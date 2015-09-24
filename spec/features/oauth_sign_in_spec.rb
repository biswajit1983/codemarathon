feature "OAuth sign in" do

  given(:mock_user_data) do
    { uid: '12345', info: {email: 'test@test.com', name: 'Some Name'} }
  end

  background do
    OmniAuth.config.add_mock(:google_oauth2, mock_user_data)
    OmniAuth.config.add_mock(:github, mock_user_data)

    visit new_user_session_path
  end

  context "when user signs up" do
    scenario "using Google" do
      click_link "Sign in with Google Oauth2"

      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_text("Successfully authenticated from Google account.")
      expect(User.count).to eq(1)
    end

    scenario "using Github" do
      click_link "Sign in with Github"

      expect(current_path).to eq(new_user_session_path)
      expect(page).to have_text("Successfully authenticated from GitHub account.")
      expect(User.count).to eq(1)
    end
  end

  context "when user signs in" do
    given(:user) { FactoryGirl.create(:user, email: mock_user_data["info"]["email"]) }

    background do
      user.confirmed_at = Time.now
      user.save
    end

    scenario "using Google" do
      puts mock_user_data
      click_link "Sign in with Google Oauth2"

      expect(current_path).to eq(root_path)
      expect(page).to have_text("Successfully authenticated from Google account.")
      expect(User.count).to eq(1)
    end

    scenario "using Github" do
      click_link "Sign in with Github"

      expect(current_path).to eq(root_path)
      expect(page).to have_text("Successfully authenticated from GitHub account.")
      expect(User.count).to eq(1)
    end
  end

end
