module CollectionsHelper
  def hotkeyed_link_to_collection(collection, &)
    link_to collection, class: "header__title btn borderless txt-large",
      style: "--btn-padding: 0.25ch 1ch 0.25ch 0.75ch; view-transistion-name: card-collection-title;",
      data: { controller: "hotkey", action: "keydown.esc@document->hotkey#click click->turbo-navigation#backIfSamePath" }, &
  end

  def referenced_collections_from(records)
    Current.user.collections.where id: records.pluck(:collection_id).uniq
  end
end
