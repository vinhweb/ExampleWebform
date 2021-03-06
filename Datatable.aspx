﻿<%@ Page MasterPageFile="~/MasterPage.master" Language="VB" AutoEventWireup="false" CodeFile="Datatable.aspx.vb" Inherits="Datatable" %>

<asp:content id="Content2" ContentPlaceHolderID="head" runat="server">
    <link href="Content/themes/base/jquery-ui.min.css" rel="stylesheet" />

    <style>
        table.dataTable tbody th, table.dataTable tbody td {
            padding: 8px 10px;
            vertical-align: baseline;
        }
        #myDatatable_length label,
        #myDatatable_filter label{
            display: grid;
            align-items: center;
            grid-template-columns: auto auto auto;
            grid-gap: 10px;
            margin-bottom: 20px
        }
        #myDatatable_paginate .btn{
            margin: 0 2px;
        }
        table.dataTable.no-footer{
            border-bottom: 0;
            margin-bottom: 15px;
        }
        table.dataTable thead th, table.dataTable thead td{
            border: none;
        }
    </style>
</asp:content>


<asp:content id="Content1" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">

    <%--Box Thêm Mới--%>
    <div id="addNew" title="Thêm Mới">
        <div class="form-group">
            <label for="stt">STT</label>
            <input type="text" class="form-control" id="stt" />
        </div>
        <div class="form-group">
            <label for="tengiupdo">Tên Giúp Đỡ</label>
            <input type="text" class="form-control" id="tengiupdo"/>
        </div>
        <div class="form-group">
            <label for="duongdan">Đường dẫn</label>
            <input type="text" class="form-control" id="duongdan"/>
        </div>
    </div>

    <%--Box Confirm--%>
    <div id="deleteConfirm" title="Xóa trường">
        <h3>Bạn có chắc là muốn xóa trường này?</h3>
    </div>

    <%--Box Confirm 2--%>
    <div id="deleteConfirm2" title="Xóa trường">
        <h3>Bạn có chắc là muốn xóa Những trường này?</h3>
    </div>

     <%--Box Update--%>
    <div id="updateBox" title="Cập nhật">
        <div class="form-group">
            <label for="ustt">STT</label>
            <input type="text" class="form-control" id="ustt" disabled="disabled" />
        </div>
        <div class="form-group">
            <label for="utengiupdo">Tên Giúp Đỡ</label>
            <input type="text" class="form-control" id="utengiupdo"/>
        </div>
        <div class="form-group">
            <label for="uduongdan">Đường dẫn</label>
            <input type="text" class="form-control" id="uduongdan"/>
        </div>
    </div>

    <%--Table--%>
    <div class="">
        <div style="margin:  0 auto 40px"> 
            <table id="myDatatable" >
            </table>
            
            <div class="clearfix" style="margin-top: 50px">
                <a id="OpenaddNew" class="btn btn-primary addnew" style="float: right; margin-left: 15px; margin-bottom: 20px; display: block">Thêm mới</a>
                <a class="btn btn-danger deleteall" style="float: right; margin-left: auto; margin-bottom: 15px; display: block">Xóa mục đã chọn</a>
            </div>
        </div>
    </div>
  
</asp:content>


<asp:content id="Content3" ContentPlaceHolderID="bottom" runat="server">
      <script>
          var tableId = "myDatatable";
          var keySearchDetail = window.location.hostname + '_' + tableId + '_DetailDatabase';

          $(document).ready(function () {
              GetTableResult();
              popupRun();

              /* Delete & check all */
              $('#CheckallXemden').click(function (event) {
                  if (this.checked) {
                      $("input[name='cidxemden[]").each(function () {
                          this.checked = true;
                      });
                  }
                  else {
                      $("input[name='cidxemden[]").each(function () {
                          this.checked = false;
                      });
                  }
              })

              $('.deleteall').click(function () {
                  $("#deleteConfirm2")
                      .dialog('open');
              })

          })

          function popupRun() {
              //Add New
              $("#addNew").dialog({
                  autoOpen: false,
                  modal: true,
                  resizable: false,
                  height: "auto",
                  width: 500,
                  buttons: {
                      "Hủy": function () {
                          $(this).dialog("close");
                      },
                      "Thêm": function () {
                          addNewClick();
                      }
                  }
              });

              $("#OpenaddNew").click(function () {
                  $("#addNew").dialog('open');
              });


              //Delete
              deleteClickPre();
              $("#deleteConfirm").dialog({
                  autoOpen: false,
                  modal: true,
                  resizable: false,
                  height: "auto",
                  width: 500,
                  buttons: {
                      "Hủy": function () {
                          $(this).dialog("close");
                      },
                      "Chính xác": function () {
                          dataId = $(this).data('dataId')
                          deleteClick(dataId)
                      }
                  }
              });

              $("#deleteConfirm2").dialog({
                  autoOpen: false,
                  modal: true,
                  resizable: false,
                  height: "auto",
                  width: 500,
                  buttons: {
                      "Hủy": function () {
                          $(this).dialog("close");
                      },
                      "Chính xác": function () {
                          deleteAllClick();
                          $(this).dialog("close");
                      }
                  }
              });



              //Update
              updateClickPre();
              $("#updateBox").dialog({
                  autoOpen: false,
                  modal: true,
                  resizable: false,
                  height: "auto",
                  width: 500,
                  buttons: {
                      "Hủy": function () {
                          $(this).dialog("close");
                      },
                      "Câp nhật": function () {
                          updateClick();
                      }
                  }
              });
          }

          function GetTableResult() {
              //Bind table to DataTable
              tableDaChuyen = $("#myDatatable").dataTable({
                  "sDom": "<'head'<'inline-left'l><'inline-left'r><'inline-right'f>><t><ip>",
                  "bProcessing": true,
                  "bStateSave": true,
                  "bServerSide": true,
                  "bSearchHighLight": true,
                  "bFilter": true,
                  "oLanguage": { "sProcessing": "Đang tìm kiếm..." },
                  "sAjaxSource": "/Handler.ashx",
                  "aoColumnDefs": [
                      { "sTitle": "#", "mData": "stt", "aTargets": [0], "bSortable": false },
                      { "sTitle": "Tên giúp đỡ", "mData": "tengiupdo", "aTargets": [1] },
                      { "sTitle": "Đường dẫn", "mData": "duongdan", "aTargets": [2] },
                      { "sTitle": "Thao tác", "mData": "thaotac", "aTargets": [3], "bSortable": false },
                      { "sTitle": "<input type='checkbox' id='CheckallXemden' />", "mData": "chon", "aTargets": [4], "bSortable": false },
                  ],
                  "fnInitComplete": CompleteInitDatatable,
                  "fnDrawCallback": DrawCallBackDatatable,
              });
          }

          function CompleteInitDatatable() {
              //Head
              $('#myDatatable_wrapper .head select').addClass('form-control');
              $('#myDatatable_wrapper .head input').addClass('form-control');

              //Body
              $('#myDatatable').addClass('table table-striped table-hover ');


          }

          function DrawCallBackDatatable() {
              console.log('oke')
              //Footer
              $('#myDatatable_wrapper .paginate_button.current').addClass('disabled');
              $('#myDatatable_wrapper .paginate_button ').addClass('btn btn-primary btn-xs');
              $('#myDatatable_wrapper .paginate_button ').removeClass('paginate_button');

              $('#myDatatable_wrapper thead tr').addClass("info");
          }

          function RefreshTable(tableId) {
              $(tableId)
                  .DataTable().ajax.reload(null, false);
          }

          function deleteClickPre() {
              $('#myDatatable tbody').on('click', '.delete', function (event) {
                  var listClass = this.classList;
                  var dataId = this.id;
                  var that = this;

                  $("#deleteConfirm")
                      .data('dataId', dataId)
                      .dialog('open');
              })
          }

          function updateClickPre() {
              $('#myDatatable tbody').on('click', '.update', function (event) {
                  var dataId = this.id;

                  $.ajax({
                      type: "POST",
                      url: "/CommonHandler.ashx",
                      data: { typepost: "updateShow", dataId: dataId },
                      dataType: 'json',
                      success: function OnSuccess(response) {
                          if (response.status == "200") {
                              $('#ustt').val(response.result.stt);
                              $('#utengiupdo').val(response.result.tengiupdo);
                              $('#uduongdan').val(response.result.duongdan);
                          } else {
                              console.log(response.message);
                          }
                      },
                      failure: function (response) {
                          console.log(JSON.stringify(error.statusText));
                      }
                  });


                  $("#updateBox")
                      .data('dataId', dataId)
                      .dialog('open');
              })
          }

          function deleteAllClick() {
              var arrayDelId = [];

              $("input[name='cidxemden[]").each(function () {
                  if (this.checked) {
                      val = $(this).val();
                      arrayDelId.push(parseInt(val));
                  }
              });

              arrayDelId = JSON.stringify(arrayDelId);
              arrayDelId = arrayDelId.replace(/[\])}[{(]/g, '');
              console.log(arrayDelId)

              /* Send to Handler */
              $.ajax({
                  type: "POST",
                  url: "/CommonHandler.ashx",
                  data: { typepost: "deletearray", dataArray: arrayDelId },
                  dataType: 'json',
                  success: function OnSuccess(response) {
                      if (response.status == "200") {
                          RefreshTable('#myDatatable');
                      } else {
                          console.log(response.message);
                      }
                  },
                  failure: function (response) {
                      console.log(JSON.stringify(error.statusText));
                  }
              });
          }

          function deleteClick(dataId) {
              $.ajax({
                  type: "POST",
                  url: "/CommonHandler.ashx",
                  data: { typepost: "deleterow", dataId: dataId },
                  dataType: 'json',
                  success: function OnSuccess(response) {
                      if (response.status == "200") {
                          RefreshTable('#myDatatable');
                          $("#deleteConfirm").dialog("close");
                      }
                      else {
                          console.log(response.message);
                      }
                  },
                  failure: function (response) {
                      console.log(JSON.stringify(error.statusText));
                  }
              });
          }

          function updateClick() {
              var stt = $('#ustt').val();
              var tengiupdo = $('#utengiupdo').val();
              var duongdan = $('#uduongdan').val();


              $.ajax({
                  type: "POST",
                  url: "/CommonHandler.ashx",
                  data: { typepost: "update", stt: stt, tengiupdo: tengiupdo, duongdan: duongdan },
                  dataType: 'json',
                  success: function OnSuccess(response) {
                      if (response.status == "200") {
                          RefreshTable('#myDatatable');
                          $("#updateBox").dialog("close");
                      }
                      else {
                          console.log(response.message);
                      }
                  },
                  failure: function (response) {
                      console.log(JSON.stringify(error.statusText));
                  }
              });
          }

          function addNewClick() {
              var listClass = this.classList;
              var dataId = this.id;
              var that = this;
              var stt = $('#stt').val();
              var tengiupdo = $('#tengiupdo').val();
              var duongdan = $('#duongdan').val();


              $.ajax({
                  type: "POST",
                  url: "/CommonHandler.ashx",
                  data: { typepost: "addnew", stt: stt, tengiupdo: tengiupdo, duongdan: duongdan },
                  dataType: 'json',
                  success: function OnSuccess(response) {
                      if (response.status == "200") {
                          RefreshTable('#myDatatable');
                          $("#addNew").dialog("close");
                      }
                      else {
                          console.log(response.message);
                      }
                  },
                  failure: function (response) {
                      console.log(JSON.stringify(error.statusText));
                  }
              });
          }

    </script>

</asp:content>