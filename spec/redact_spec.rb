$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
require 'rubygems'
require 'rack/mock'
require 'spec'
require 'rack/redact'

TEST_DIR = File.join(File.dirname(__FILE__), 'test_app')
CONFIG_FILE = File.join(TEST_DIR, 'config', 'redacted.yml')

describe "Rack::Redact" do
  before(:each) do
    @redacted = %w(foo bar baz)
  end

  it "should redact a word in html" do
    @app = app_with_response("<a>Sample foo response</a>")

    req = Rack::MockRequest.new(Rack::Redact.new(@app, @redacted))
    res = req.get("/")
    res.body.should =~ /\*\*\*/
    res.body.should_not =~ /foo/
  end

  it "should redact a word outside html" do
    @app = app_with_response("Sample foo response bar")

    req = Rack::MockRequest.new(Rack::Redact.new(@app, @redacted))
    res = req.get("/")
    res.body.should == "Sample *** response ***"
  end

  it "should redact a word inside an html tag with just stars" do
    @app = app_with_response("<foo>Sample response</foo>")

    req = Rack::MockRequest.new(Rack::Redact.new(@app, @redacted))
    res = req.get("/")
    res.body.should == "<***>Sample response</***>"
  end

  def app_with_response(text)
    lambda { |env| [200, {'Content-Type' => 'text/html',}, [text]] }
  end
end
