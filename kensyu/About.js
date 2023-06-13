$(document).ready(function () {
    $('#SearchButton').click(function (e) {
        e.preventDefault(); // Prevent the default form submission
        console.log("SearchButton clicked");
        $.ajax({
            type: 'POST',
            url: 'About.aspx/GetSearchResultsForWebMethod',
            contentType: 'application/json; charset=utf-8',
            dataType: 'json',
            success: function (data) {
                var results = JSON.parse(data.d); // .d is used in ASP.NET WebForms to access the data.

                // Process the received data here. For example, display it in a GridView.
                // This will be dependent on your specific implementation
            }
        });
    });
});