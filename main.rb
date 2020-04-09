# frozen_string_literal: true

require 'selenium-webdriver'
require 'httparty'
require_relative 'browser_actions'
require_relative 'messages'
require_relative 'issue_comment'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

DURATION_OF_STATUS = { css: 'tbody tr:last-child td:nth-child(2)' }.freeze

AKEY = '5ad70a86c014c830b53303cf2a648534852890f4'
HOST = 'http://redmine.igatec.com/redmine'

OFFSET = 0

STATUS_HASH = { acceptance: ['9', Messages::SoonClosedMessage.new.msg],
                approbation: ['3', Messages::LongApprobationMessage.new.msg] }
              .freeze

def get_issues(project_id, status_id, offset, akey)
  issue_list = []
  path_project = "/issues.json?key=#{akey}&project_id=#{project_id}&status_id=#{status_id}&limit=100&offset=#{offset}"
  response_parsed = HTTParty.get(HOST + path_project)
  issues_parsed = response_parsed['issues']
  issues_parsed.each do |issue|
    issue_list << issue['id']
  end
  if response_parsed['total_count'] > issue_list.length
    offset += 100
    get_issues(project_id, status_id, offset, akey)
  end
  issue_list
end

project = ARGV[0]
status = ARGV[1]
limit_of_days = ARGV[2]
if ARGV.empty?
  project = 107
  status = 'approbation'
  limit_of_days = 30
end

issues_to_process = get_issues(project, STATUS_HASH[status.to_sym][0], OFFSET,
                               AKEY)
options = Selenium::WebDriver::Firefox::Options.new(args: ['-headless'])
driver = Selenium::WebDriver.for :firefox, options: options
path_to_issue = '/issues/2541'
driver.navigate.to(HOST + path_to_issue)
BrowserActions.auth driver
puts 'Here it is list of issues to process:'
puts issues_to_process

issues_to_process.each do |issue_id|
  path_to_status = "/issues/#{issue_id}/status"
  driver.navigate.to(HOST + path_to_status)
  if driver.title == 'IGA Technologies'
    driver.find_element(xpath: '//input[@type="text"]').clear
    driver.find_element(xpath: '//input[@type="text"]').send_keys('igabot')
    driver.find_element(xpath: '//input[@type="password"]').clear
    driver.find_element(xpath: '//input[@type="password"]').send_keys('2OyD6ppE')
    element1 = driver.find_element(xpath: '//input[@type="submit"]')
    driver.execute_script('arguments[0].click()', element1)
  end
  sleep 2
  duration = (Time.now - Time.parse(driver.find_element(DURATION_OF_STATUS).text)).to_i / (60 * 60 * 24)
  if duration > limit_of_days.to_i
    IssueComment.new(issue_id, STATUS_HASH[status.to_sym][1])
    puts [(HOST + '/' + issue_id.to_s), "#{duration} д."]
  end
end
