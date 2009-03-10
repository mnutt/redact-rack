module Rack
  class Redact
    def initialize(app, path)
      @app = app
      @path = ::File.expand_path(path)
    end

    def redact_expr
      redacted_list = YAML::load_file(File.join(@path, "config", "redacted.yml"))
      redacted_list.join("|")
    end
    
    def call(env)
      response = @app.call(env)
      response[2].map! { |body|
        # Use pretty <span> tags when dealing with html
        body.gsub!(/>([^<]*)</) do |inner|
          inner.gsub(/#{redact_expr}/) { |m|
            "<span style='background-color: #000; color: #000'>#{"*" * m.size}</span>"
          }
        end

        # Use regular stars inside html tags or anywhere else that we don't want a <span>
        body.gsub!(/#{redact_expr}/) do |m|
          "*" * m.size
        end

        body
      }

      response
    end
  end
end
