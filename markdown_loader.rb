require 'kramdown'
require 'kramdown-parser-gfm'
require 'yaml'
require_relative './kramdown_ext'

class MarkdownLoader
  def self.load_meta(filepath)
    state = :begin
    meta_lines = []
    File.open(filepath).each do |line|
      case state
      when :begin
        if line.strip == '---'
          state = :meta_info
        end
      when :meta_info
        if line.strip != '---'
          meta_lines << line
        else
          state = :body
          break
        end
      end
    end

    raise unless state == :body

    YAML.load(meta_lines.join("\n"))
  end

  def self.load_body(filepath)
    state = :begin
    md_lines = []
    File.open(filepath).each do |line|
      case state
      when :begin
        if line.strip == '---'
          state = :meta_info
        end
      when :meta_info
        if line.strip == '---'
          state = :body
        end
      when :body
        md_lines << line
      end
    end

    md_lines.join("\n")
  end
end
