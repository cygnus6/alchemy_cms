require 'spec_helper'

describe 'alchemy/essences/_essence_editor_view' do
  let(:file)       { File.new(File.expand_path('../../../fixtures/image with spaces.png', __FILE__)) }
  let(:attachment) { mock_model('Attachment', file: file, name: 'image', file_name: 'Image', icon_css_class: 'image') }
  let(:essence)    { mock_model('EssenceFile', attachment: attachment) }
  let(:content)    { mock_model('Content', essence: essence, settings: {}, dom_id: 'essence_file_1', form_field_name: '"contents[1][attachment_id]"') }

  subject do
    render partial: "alchemy/essences/essence_file_editor", locals: {content: content}
    rendered
  end

  before do
    view.class.send :include, Alchemy::Admin::BaseHelper
    allow(view).to receive(:_t).and_return('')
    allow(view).to receive(:label_and_remove_link).and_return('')
  end

  context 'with ingredient present' do
    before do
      allow(content).to receive(:ingredient).and_return(attachment)
    end

    it "renders a hidden field with attachment id" do
      is_expected.to have_selector("input[type='hidden'][value='#{attachment.id}']")
    end

    it "renders a link to open the attachment library overlay" do
      is_expected.to have_selector("a.assign_file[href='/admin/attachments?content_id=#{content.id}&options=%7B%7D']")
    end

    it "renders a link to edit the essence" do
      is_expected.to have_selector("a.edit_file[href='/admin/essence_files/#{essence.id}/edit?options=%7B%7D']")
    end

    context 'with content settings `only`' do
      it "renders a link to open the attachment library overlay with only pdfs" do
        expect(content).to receive(:settings).at_least(:once).and_return({only: 'pdf'})
        is_expected.to have_selector("a.assign_file[href='/admin/attachments?content_id=#{content.id}&only=pdf&options=%7B%7D']")
      end
    end

    context 'with content settings `except`' do
      it "renders a link to open the attachment library overlay without pdfs" do
        expect(content).to receive(:settings).at_least(:once).and_return({except: 'pdf'})
        is_expected.to have_selector("a.assign_file[href='/admin/attachments?content_id=#{content.id}&except=pdf&options=%7B%7D']")
      end
    end
  end

  context 'without ingredient present' do
    before do
      allow(content).to receive(:ingredient).and_return(nil)
    end

    it "does not render a hidden field with attachment id" do
      is_expected.to_not have_selector("input[type='hidden']")
    end
  end
end
