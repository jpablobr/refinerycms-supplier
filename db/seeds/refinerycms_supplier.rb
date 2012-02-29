::User.find(:all).each do |user|
  if user.plugins.where(:name => 'refinerycms_supplier').blank?
    user.plugins.create(:name => "refinerycms_supplier",
                        :position => (user.plugins.maximum(:position) || -1) +1)
  end
end if defined?(::User)

if defined?(::Page)
  page = ::Page.create(
    :title => "Supplier",
    :link_url => "/supplier",
    :deletable => false,
    :position => ((Page.maximum(:position, :conditions => {:parent_id => nil}) || -1)+1),
    :menu_match => "^/suppliers?(\/|\/.+?|)$"
  )

  ::Page.default_parts.each do |default_page_part|
    page.parts.create(:title => default_page_part, :body => nil)
  end
end