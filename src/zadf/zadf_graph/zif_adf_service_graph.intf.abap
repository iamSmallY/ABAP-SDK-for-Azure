INTERFACE zif_adf_service_graph
  PUBLIC .
  TYPES: BEGIN OF hash,
            quickXorHash TYPE string,
            sha1Hash TYPE string,
            sha256Hash TYPE string,
         END OF hash,

         BEGIN OF parentInfo,
            id TYPE string,
            name TYPE string,
            path TYPE string,
         END OF parentInfo,

         BEGIN OF fileInfo,
            mimeType TYPE string,
            hashes TYPE hash,
         END OF fileInfo,

         BEGIN OF folderInfo,
            childCount TYPE i,
         END OF folderInfo,

         BEGIN OF item,
           createdDatetime TYPE string,
           lastModifiedDatetime TYPE string,
           id TYPE string,
           name TYPE string,
           size TYPE integer,
           webUrl TYPE string,
           parentReference TYPE parentInfo,
           file TYPE fileInfo,
           folder TYPE folderInfo,
         END OF item.

  TYPES: items TYPE STANDARD TABLE OF item WITH DEFAULT KEY.

  METHODS get_files
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RETURNING
      VALUE(rt_files)  TYPE items
    RAISING
      zcx_adf_service .

  METHODS get_file_by_path
    IMPORTING
        VALUE(iv_aad_token) TYPE string
        VALUE(iv_user_id) TYPE string
        VALUE(iv_file_path) TYPE string OPTIONAL
    EXPORTING
        VALUE(ev_http_status) TYPE i
    RETURNING
        VALUE(rt_file) TYPE item
    RAISING
        zcx_adf_service .

  METHODS search_file
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
      VALUE(iv_search_pattern) TYPE string
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RETURNING
      VALUE(rt_files) TYPE items
    RAISING
      zcx_adf_service .

  METHODS create_folder
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
      VALUE(iv_parent_id) TYPE string OPTIONAL
      VALUE(iv_folder_name) TYPE string
      VALUE(iv_conflict_behavior) TYPE string
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RETURNING
      VALUE(rt_folder) TYPE item
    RAISING
      zcx_adf_service .

  METHODS upload_file_by_path
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
      VALUE(iv_path) TYPE string
      VALUE(iv_content_type) TYPE string
      VALUE(iv_content) TYPE xstring
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RETURNING
      VALUE(rt_file) TYPE item
    RAISING
      zcx_adf_service .

  METHODS upload_file_by_id
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
      VALUE(iv_file_id) TYPE string
      VALUE(iv_content_type) TYPE string
      VALUE(iv_content) TYPE xstring
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RETURNING
      VALUE(rt_file) TYPE item
    RAISING
      zcx_adf_service .

  METHODS update_file
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
      VALUE(iv_file_id) TYPE string
      VALUE(iv_new_name) TYPE string
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RETURNING
      VALUE(rt_file) TYPE item
    RAISING
      zcx_adf_service .

  METHODS delete_file
    IMPORTING
      VALUE(iv_aad_token) TYPE string
      VALUE(iv_user_id) TYPE string
      VALUE(iv_file_id) TYPE string
    EXPORTING
      VALUE(ev_http_status) TYPE i
    RAISING
      zcx_adf_service .

  METHODS get_file_download_url
    IMPORTING
        VALUE(iv_aad_token) TYPE string
        VALUE(iv_user_id) TYPE string
        VALUE(iv_file_id) TYPE string
    EXPORTING
        VALUE(ev_http_status) TYPE i
    RETURNING
        VALUE(rt_download_url) TYPE string
    RAISING
        zcx_adf_service .

ENDINTERFACE.
