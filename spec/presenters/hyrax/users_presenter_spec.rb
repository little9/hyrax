describe Hyrax::UsersPresenter do
  let(:instance) { described_class.new }
  before do
    let(:user1) { FactoryGirl.create(:user, display_name: "Charles Francis Xavier") }
    let(:user2) { FactoryGirl.create(:admin, display_name: "Frank Lloyd Wright") }
  end

  describe "#users" do
    it "includes all users" do
      subject { instance.users }
      it { is expected.to match_array [user1, user2] }
    end
  end

  describe "#user_count" do
    subject { instance.user_count }
    it { is_expected.to eq 2 }
  end

  describe "#repository_administrator_count" do
    subject { instance.repository_administrator_count }
    it { is_expected.to eq 1 }
  end
end
