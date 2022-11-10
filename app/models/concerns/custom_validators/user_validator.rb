class CustomValidators::UserValidator < ActiveModel::Validator
  def validate(_record)
    puts '<==========='.colorize(background: :red)
  end
end
