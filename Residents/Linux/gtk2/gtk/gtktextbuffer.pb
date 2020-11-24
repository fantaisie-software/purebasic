Structure GtkTextBuffer
  parent_instance.GObject
 *tag_table.GtkTextTagTable
 *btree.GtkTextBTree
 *clipboard_contents_buffers.GSList
 *selection_clipboards.GSList
 *log_attr_cache.GtkTextLogAttrCache
  user_action_count.l
  packed_flags.l
  ; modified:1
EndStructure

Structure GtkTextBufferClass
  parent_class.GObjectClass
 *insert_text
 *insert_pixbuf
 *insert_child_anchor
 *delete_range
 *changed
 *modified_changed
 *mark_set
 *mark_deleted
 *apply_tag
 *remove_tag
 *begin_user_action
 *end_user_action
 *_gtk_reserved
 *_gtk_reserved2
 *_gtk_reserved3
 *_gtk_reserved4
 *_gtk_reserved5
 *_gtk_reserved6
EndStructure

