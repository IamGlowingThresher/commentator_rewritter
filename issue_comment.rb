# frozen_string_literal: true

require_relative 'messages'
require_relative 'browser_actions'

EDIT_BUTTON = { xpath: '/html/body/div[1]/div[2]/div[1]/div[3]/div[2]/div[1]/a[1]' }.freeze
IFRAME = { css: '.cke_wysiwyg_frame' }.freeze
TEXTAREA = { css: 'body' }.freeze
COMMENT_BUTTON = { css: '#issue-form > input:nth-child(7)' }.freeze

class IssueComment
  def initialize(issue, message)
    driver = BrowserActions.new
    driver.navigate_to("#{HOST}/issues/#{issue}")
    driver.auth
    driver.click_at_elem(EDIT_BUTTON)
    sleep 1
    iframe = driver.get_iframe(IFRAME)
    driver.switch_to_frame iframe
    driver.send_keys_to_elem(TEXTAREA, message)
    driver.switch_back
    driver.click_at_elem(COMMENT_BUTTON)
    driver.quit
  end
end