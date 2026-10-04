require "rails_helper"

RSpec.describe "Editor formats task description", type: :system, js: true, optional: true do
  let(:editor) { create(:user, :editor) }

  before do
    login_as(editor)
    create(:project)
    visit new_task_path
    page.driver.browser.manage.window.resize_to(800, 1600)
  end

  def content_element
    find("lexxy-editor [contenteditable='true']")
  end

  def type_in_editor(text)
    content_element.click
    content_element.send_keys(text)
  end

  def toolbar
    find("lexxy-toolbar")
  end

  it "toggles a heading" do
    type_in_editor("Heading")

    toolbar.find("button[name='heading4']").click
    expect(content_element).to have_css("h4", text: "Heading")
    expect(toolbar).to have_css("button[name='heading4'][aria-pressed='true']")

    toolbar.find("button[name='heading4']").click
    expect(content_element).to have_no_css("h4")
    expect(content_element).to have_css("p", text: "Heading")
    expect(toolbar).to have_css("button[name='heading4'][aria-pressed='false']")
  end

  it "disables the headings excluded on the task form" do
    expect(toolbar).to have_css("button[name='heading1'][disabled]")
    expect(toolbar).to have_css("button[name='heading2'][disabled]")
    expect(toolbar).to have_css("button[name='heading3'][disabled]")
  end

  it "formats the selected text in bold" do
    type_in_editor("Bold")
    content_element.send_keys([ :shift, :home ])

    toolbar.find("button[name='bold']").click
    expect(content_element).to have_css("b, strong", text: "Bold")
    expect(toolbar).to have_css("button[name='bold'][aria-pressed='true']")
  end

  it "links the selected text" do
    type_in_editor("Example")
    content_element.send_keys([ :shift, :home ])

    toolbar.find("button[name='link']").click
    within(toolbar.find("lexxy-link-dropdown [data-dropdown-panel]")) do
      find("input[type='url']").fill_in(with: "https://example.com")
      click_on "Verlinken"
    end

    expect(content_element).to have_link("Example", href: "https://example.com")
  end

  it "inserts a table and a divider" do
    type_in_editor("Text")

    toolbar.find("button[name='table']").click
    expect(content_element).to have_css("table")

    toolbar.find("button[name='divider']").click
    expect(content_element).to have_css("hr")
  end

  it "shows the highlight colors" do
    type_in_editor("Color")
    content_element.send_keys([ :shift, :home ])

    toolbar.find("button[name='highlight']").click
    expect(toolbar).to have_css("lexxy-highlight-dropdown .lexxy-highlight-colors button", minimum: 1)
  end

  it "uploads an attached image" do
    type_in_editor("Image")

    toolbar.find("button[name='file']").click
    # Lexxy briefly appends the file input to the editor
    find("lexxy-editor input[type='file']", visible: :all)
      .attach_file(Rails.root.join("spec/assets/images/for-tests.jpg"), make_visible: true)

    expect(content_element).to have_css("img[src*='for-tests']")
    expect(ActiveStorage::Blob.last.filename.to_s).to eq("for-tests.jpg")
  end

  it "saves the formatted description" do
    select "Project title", from: "task_form_project_id"
    fill_in "Titel", with: "Formatted task"
    fill_in_rich_textarea with: "<h4>Agenda</h4><p>Some <strong>bold</strong> text</p>"
    click_on "Speichern"

    expect(page).to have_content("Aufgabe wurde erfolgreich erstellt.")
    expect(Task.last.description.body.to_html).to include("<h4>Agenda</h4>")
    expect(page).to have_css(".lexxy-content h4", text: "Agenda")
  end
end
