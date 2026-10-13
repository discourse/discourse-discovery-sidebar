# frozen_string_literal: true

RSpec.describe "Discovery sidebar" do
  let!(:theme) { upload_theme_or_component }

  fab!(:admin)
  fab!(:user)
  fab!(:parent_category) { Fabricate(:category, name: "Product") }
  fab!(:subcategory) do
    Fabricate(:category, name: "Product ideas", parent_category: parent_category)
  end
  fab!(:other_category) { Fabricate(:category, name: "Off topic") }

  let(:sidebar) { ".discovery-layout__sidebar" }

  def update_setting(name, value)
    theme.update_setting(name, value)
    theme.save!
  end

  def create_event(title, starts_at)
    start = starts_at.utc.strftime("%Y-%m-%d %H:%M")
    PostCreator.create!(
      admin,
      title:,
      raw: "[event start=\"#{start}\" status=\"public\" timezone=\"UTC\"]\n[/event]",
    )
  end

  before { sign_in(user) }

  describe "layout" do
    it "renders the panels on topic lists" do
      visit("/latest")

      expect(page).to have_css("#{sidebar} .block-space.--global")
      expect(page).to have_css("#{sidebar} .block-topics")
      expect(page).to have_css("#{sidebar} .block-resources")
    end

    it "renders no panel on the categories page" do
      visit("/categories")

      expect(page).to have_css(".category-list")
      expect(page).to have_no_css(".block-panel")
    end
  end

  describe "space panel" do
    it "lists the top-level categories on global lists" do
      visit("/latest")

      within("#{sidebar} .block-space") do
        expect(page).to have_css(".block-space__name", text: parent_category.name)
        expect(page).to have_css(".block-space__name", text: other_category.name)
        expect(page).to have_no_css(".block-space__name", text: subcategory.name)
      end
    end

    it "shows the parent and its subcategories on a subcategory page, the current one marked" do
      visit(subcategory.url)

      within("#{sidebar} .block-space") do
        expect(page).to have_css(".block-space__head", text: parent_category.name)
        expect(page).to have_css(".block-space__item.--current", text: subcategory.name)
      end
    end

    it "applies a scoped entry on its categories and the fallback elsewhere" do
      update_setting(
        :spaces,
        [
          { "categories" => [other_category.id], "all_spaces_url" => "/categories" },
          { "all_spaces_url" => "/latest" },
        ],
      )

      visit(other_category.url)
      expect(page).to have_css("#{sidebar} .block-space .block-panel__link[href$='/categories']")

      visit(parent_category.url)
      expect(page).to have_css("#{sidebar} .block-space .block-panel__link[href$='/latest']")
    end

    it "shows only on scoped categories when there is no fallback entry" do
      update_setting(:spaces, [{ "categories" => [other_category.id], "all_spaces_url" => "/" }])

      visit(other_category.url)
      expect(page).to have_css("#{sidebar} .block-space")

      visit(parent_category.url)
      expect(page).to have_css("#{sidebar} .block-topics")
      expect(page).to have_no_css("#{sidebar} .block-space")
    end
  end

  describe "events panel" do
    before do
      SiteSetting.discourse_events_enabled = true
      SiteSetting.discourse_post_event_enabled = true
    end

    it "lists upcoming events" do
      create_event("Community meetup next week", 3.days.from_now)

      visit("/latest")

      within("#{sidebar} .block-events") do
        expect(page).to have_css(".block-panel__title", text: "Upcoming events")
        expect(page).to have_css(".block-events__name", text: "Community meetup next week")
      end
    end

    it "falls back to recent events when none are upcoming" do
      create_event("Community meetup last week", 5.days.ago)

      visit("/latest")

      within("#{sidebar} .block-events") do
        expect(page).to have_css(".block-panel__title", text: "Recent events")
        expect(page).to have_css(".block-events__name", text: "Community meetup last week")
      end
    end

    it "hides the panel when the events plugin is disabled" do
      SiteSetting.discourse_events_enabled = false

      visit("/latest")

      expect(page).to have_css("#{sidebar} .block-space")
      expect(page).to have_no_css("#{sidebar} .block-events")
    end
  end

  describe "leaderboard panel" do
    fab!(:leaderboard) { Fabricate(:gamification_leaderboard, name: "Top helpers") }
    fab!(:scorer) { Fabricate(:user, username: "top_scorer") }

    before do
      SiteSetting.discourse_gamification_enabled = true
      Fabricate(
        :gamification_leaderboard_score,
        leaderboard_id: leaderboard.id,
        user_id: scorer.id,
        score: 25,
      )
      DiscourseGamification::LeaderboardCachedView.create_all
    end

    it "lists the default leaderboard under its own name" do
      visit("/latest")

      within("#{sidebar} .block-leaderboard") do
        expect(page).to have_css(".block-panel__title", text: "Top helpers")
        expect(page).to have_css(".block-leaderboard__name", text: "top_scorer")
      end
    end

    it "hides the panel when the gamification plugin is disabled" do
      SiteSetting.discourse_gamification_enabled = false

      visit("/latest")

      expect(page).to have_css("#{sidebar} .block-space")
      expect(page).to have_no_css("#{sidebar} .block-leaderboard")
    end
  end

  describe "topics panel" do
    fab!(:tag) { Fabricate(:tag, name: "featured") }
    fab!(:tagged_topic) do
      Fabricate(:topic_with_op, title: "A tagged topic about pricing", tags: [tag])
    end
    fab!(:untagged_topic) { Fabricate(:topic_with_op, title: "An untagged topic about billing") }
    fab!(:pinned_topic) do
      Fabricate(:topic_with_op, title: "A pinned topic with the rules", pinned_at: 1.hour.ago)
    end

    before { update_setting(:topic_lists, [{ "list" => "latest" }]) }

    it "leaves out pinned topics" do
      visit("/latest")

      within("#{sidebar} .block-topics") do
        expect(page).to have_css(".block-topics__title", text: tagged_topic.title)
        expect(page).to have_css(".block-topics__title", text: untagged_topic.title)
        expect(page).to have_no_css(".block-topics__title", text: pinned_topic.title)
      end
    end

    it "narrows the list to the configured tag" do
      update_setting(:topic_lists, [{ "list" => "latest", "tag" => [tag.name] }])

      visit("/latest")

      within("#{sidebar} .block-topics") do
        expect(page).to have_css(".block-topics__title", text: tagged_topic.title)
        expect(page).to have_no_css(".block-topics__title", text: untagged_topic.title)
      end
    end
  end
end
