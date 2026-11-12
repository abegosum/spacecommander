require "application_system_test_case"

# Verifies the system test driver stack itself (Capybara + Selenium +
# headless Chrome + the Puma test server) still works end to end. Uses a
# trivial static Rack app rather than a real app route, since every real
# controller here depends on live network calls to NetApp infrastructure.
class SmokeTest < ApplicationSystemTestCase
  def setup
    @original_app = Capybara.app
    Capybara.app = ->(_env) { [200, { "Content-Type" => "text/html" }, ["<html><body><h1>capybara smoke test</h1></body></html>"]] }
  end

  def teardown
    Capybara.app = @original_app
  end

  test "drives a real browser against the test server" do
    visit "/"
    assert_selector "h1", text: "capybara smoke test"
  end
end
