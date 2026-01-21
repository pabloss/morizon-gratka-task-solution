$(function () {
    let order = '';
    let sortBy = '';
    let $sortable = $(".sortable");
    let $searchButton = $("button[name='search_form[search]']");

    function sendRequest(sortBy = '', order = '') {
        let tableBodyHtml = '';
        let query = $("form").serialize();
        $.ajax({
            url: "/users?" + query +
                (sortBy.length ? ('&sort_by=' + sortBy) : '') +
                (order.length ? ('&order=' + order) : '')
        })
            .done(function (resp) {
                if (resp.hasOwnProperty('data')) {
                    for (const user of resp.data) {
                        if (
                            user.hasOwnProperty('id') &&
                            user.hasOwnProperty('first_name') &&
                            user.hasOwnProperty('last_name') &&
                            user.hasOwnProperty('gender') &&
                            user.hasOwnProperty('birthdate')
                        ) {
                            tableBodyHtml += `<tr>` +
                                '<td>' + user.first_name + '</td>' +
                                '<td>' + user.last_name + '</td>' +
                                '<td>' + (user.gender === 'male' ? 'mężczyzna' : 'kobieta')  + '</td>' +
                                '<td>' + user.birthdate + '</td>' +
                                `<td>
                                    <button class="update" data-id="${user.id}" value="Edycja"><label>Edycja</label></button>
                                    <button class="delete" data-id="${user.id}" value="Usuwanie"><label>Usuń</label></button>
                                </td>` +
                                '</tr>';
                        }
                    }
                    $('tbody').html(tableBodyHtml);
                }
            });
    }
    sendRequest(sortBy, order);

    $("body")
        .on("click", "button.update", function () {
            let id = $(this).data('id');
            window.location.href = `users/${id}`;
        })
        .on("click", "button.delete", function () {
            let id = $(this).data('id');
            $.ajax({
                type: "DELETE",
                url: `users/${id}`,
            }).done(function () {
                sendRequest(sortBy, order);
            });
        });

    $searchButton.on('click', function () {

        let $asc = $('.asc');
        let $desc = $('.desc');

        if ($asc.length && $asc.get(0).className.split(" ").length > 2) {
            order = 'asc';
            sortBy = $asc.get(0).className.split(" ")[1];
        }
        if ($desc.length && $desc.get(0).className.split(" ").length > 2) {
            order = 'desc';
            sortBy = $desc.get(0).className.split(" ")[1];
        }

        sendRequest(sortBy, order);
    });

    $sortable.on('click', function () {
        let $this = $(this);
        let asc = $this.hasClass('asc');
        let desc = $this.hasClass('desc');
        $sortable.removeClass('asc').removeClass('desc');
        if (desc || (!asc && !desc)) {
            $this.addClass('asc');
        } else {
            $this.addClass('desc');
        }
        let [, sortBy, order] = this.className.split(" ");

        sendRequest(sortBy, order);
    });
});
