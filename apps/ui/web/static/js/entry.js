import $ from "jquery"
import datatables from "datatables.net"


// load datatables
datatables()

$(function() {
  $('#entry-table').DataTable()
})

export default {}
