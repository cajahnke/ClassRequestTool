$(function () {
  
  // Send user to make a request with given repository
  $('#select-repo button').on('click', function(e) {
    window.location.href = '/courses/new?repository=' + $('#repo').val();
  });
});
