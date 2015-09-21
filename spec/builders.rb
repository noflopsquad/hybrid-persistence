class PersonBuilder
  def initialize
    @first_name = nil
    @last_name = nil
  end

  def with_first_name first_name
    @first_name = first_name
    self
  end

  def with_last_name last_name
    @last_name = last_name
    self
  end

  def with_email email
    @email = email
    self
  end

  def with_phone phone
    @phone = phone
    self
  end

  def with_credit_card credit_card
    @credit_card = credit_card
    self
  end

  def with_title title
    @title = title
    self
  end

  def build
    raise ArgumentError.new("Missing Person invariants") if missing_invariant?

    person = Person.new(@first_name, @last_name)
    person.title = @title unless @title.nil?
    person.email = @email unless @email.nil?
    person.credit_card = @credit_card unless @credit_card.nil?
    person.phone = @phone unless @phone.nil?
    person
  end

  private
  def missing_invariant?
    @first_name.nil? || @last_name.nil?
  end
end

class AddressBuilder
  def initialize
    @street_name = nil
    @street_address = nil
  end

  def with_street_name street_name
    @street_name = street_name
    self
  end

  def with_street_address street_address
    @street_address = street_address
    self
  end

  def in city
    @city = city
    self
  end

  def build
    raise ArgumentError.new("Missing Address invariants") if missing_invariant?

    address = Address.new(@street_name, @street_address)
    address.city = @city unless @city.nil?
    address
  end

  private
  def missing_invariant?
    @street_name.nil? || @street_address.nil?
  end
end
