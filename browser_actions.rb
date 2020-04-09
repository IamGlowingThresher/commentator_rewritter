require 'selenium-webdriver'

class BrowserActions
  def initialize(browser = eval("Selenium::WebDriver.for :firefox"))
    @wait = Selenium::WebDriver::Wait.new(timeout: 10)
    @browser = browser
    @time = Time.now
  end

  def auth
    @browser.find_element(xpath: '//input[@type="text"]').clear
    @browser.find_element(xpath: '//input[@type="text"]').send_keys("igabot")
    @browser.find_element(xpath: '//input[@type="password"]').clear
    @browser.find_element(xpath: '//input[@type="password"]').send_keys("2OyD6ppE")
    element1 = @browser.find_element(xpath: '//input[@type="submit"]')
    @browser.execute_script("arguments[0].click()", element1)
  end

  def self.auth(driver)
    driver.find_element(xpath: '//input[@type="text"]').clear
    driver.find_element(xpath: '//input[@type="text"]').send_keys("igabot")
    driver.find_element(xpath: '//input[@type="password"]').clear
    driver.find_element(xpath: '//input[@type="password"]').send_keys("2OyD6ppE")
    element1 = driver.find_element(xpath: '//input[@type="submit"]')
    driver.execute_script("arguments[0].click()", element1)
  end

  def get_iframe selector
    @browser.find_element(selector)
  end

  def switch_to_frame elem
    @browser.switch_to.frame(elem)
  end

  def switch_back
    @browser.switch_to.default_content
  end

  def send_keys_to_elem(selector, keys)
    wait4it selector
    @browser.find_element(selector).clear
    @browser.find_element(selector).send_keys(keys)
  end

  def navigate_to(url)
    @browser.get(url)
  end

  def click_at_elem(selector)
    wait4it selector
    elem = @browser.find_element(selector)
    @browser.execute_script('arguments[0].scrollIntoView(true);', elem)
    puts "scroll to elem #{selector}"
    @browser.find_element(selector).click
    puts "click at elem #{selector}"
  end

  def hash_to_string_selector hash_selector
    hash_selector[:xpath] if hash_selector[:css] == nil?
    hash_selector[:css]
  end

  def screen_shot
    @browser.save_screenshot "./screens/#{Time.now.strftime("failshot__%d_%m_%Y__%H_%M_%S")}.png"
  end

  def zadr_click_at_elem(selector)
    @wait.until do
      @browser.find_element(selector).displayed?
    end
    js_elem = hash_to_string_selector selector
    @browser.execute_script("var e = new Event('click');$('#{js_elem}')[0].dispatchEvent(e)")
    puts "send vanilla js click event to #{selector}"
  end

  def auth_redmine(driver=eval(Selenium::WebDriver.for :firefox))
    driver.find_element(xpath: '//input[@type="text"]').clear
    driver.find_element(xpath: '//input[@type="text"]').send_keys("igabot")
    driver.find_element(xpath: '//input[@type="password"]').clear
    driver.find_element(xpath: '//input[@type="password"]').send_keys("2OyD6ppE")
    element1 = driver.find_element(xpath: '//input[@type="submit"]')
    driver.execute_script("arguments[0].click()", element1)
  end

  def wait4it(selector)
    @wait.until { @browser.find_element(selector).displayed? }
  end

  def quit
    @browser.quit
  end
end