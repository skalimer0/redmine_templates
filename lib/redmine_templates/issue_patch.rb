require_dependency 'issue'

class Issue < ActiveRecord::Base

  def generated_subject(pattern:)
    pattern.gsub(/{\w+}/) do |attribute|
      attribute = attribute.delete_prefix("{").delete_suffix("}")

      case attribute
      when /^cf_\d+/
        cf_identifier = attribute.delete_prefix("cf_")
        cf = CustomField.where(id: cf_identifier).first
        self.custom_field_value(cf) if cf.present?
      when /^cf_\w+/
        cf_identifier = attribute.delete_prefix("cf_")
        cf = CustomField.where("lower(name) = ? ", cf_identifier.humanize.downcase).first
        self.custom_field_value(cf) if cf.present?
      else
        self.send(attribute.to_sym) if self.respond_to?(attribute)
      end

    end

  end

end
