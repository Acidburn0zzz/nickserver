require 'test_helper'
require 'nickserver/nicknym/source'
require 'nickserver/email_address'

#
# Please note the Readme.md file in this directory
#
class RemoteNicknymSourceTest < Minitest::Test

  def setup
    super
    Celluloid.boot
  end

  def teardown
    Celluloid.shutdown
    super
  end

  def test_availablility_check
    skip unless source.available_for? 'mail.bitmask.net'
    refute source.available_for? 'dl.bitmask.net'   # not a provider
  end

  def test_successful_query
    response = source.query(email_with_key)
    skip if response.status == 404
    json = JSON.parse response.content
    assert_equal email_with_key.to_s, json["address"]
    refute_empty json["openpgp"]
  end

  def test_not_found
    response = source.query(email_without_key)
    skip if response.status == 200
    assert response.status == 404
  end

  protected

  def source
    @source ||= Nickserver::Nicknym::Source.new
  end

  def email_with_key
    Nickserver::EmailAddress.new('test@mail.bitmask.net')
  end

  def email_without_key
    Nickserver::EmailAddress.new('pleaseneverusethisemailweuseittotest@mail.bitmask.net')
  end

end
