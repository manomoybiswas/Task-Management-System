require 'rails_helper'

RSpec.describe TasksHelper, type: :helper do
  let (:user1) {create(:employee)}
  let (:user2) {create(:admin)}
  let (:category1) {create(:category)}
  let (:task1) { create(:assigned_task1, task_category: category1.id, assign_task_to: user1.id, assign_task_by: user2.id)}
  describe "#find_task" do
    it "is expected to return task" do
      expect(helper.find_task(task1.id).id).to eq(task1.id)
    end
  end
  describe "#find_uesr_name" do
    it "is expected to return user name" do
      expect(helper.find_user_name(user1.id)).to eq(user1.name)
    end
  end
end