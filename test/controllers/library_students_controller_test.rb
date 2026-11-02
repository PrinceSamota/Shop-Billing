require "test_helper"

class LibraryStudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get library_students_index_url
    assert_response :success
  end

  test "should get show" do
    get library_students_show_url
    assert_response :success
  end

  test "should get new" do
    get library_students_new_url
    assert_response :success
  end

  test "should get create" do
    get library_students_create_url
    assert_response :success
  end

  test "should get edit" do
    get library_students_edit_url
    assert_response :success
  end

  test "should get update" do
    get library_students_update_url
    assert_response :success
  end
end
