window.addEventListener('message', function (event) {

	if (event.data.action == 'display') {
		$('.bar')[0].style.setProperty('bottom', (event.data.bottom + 2));
		$('.bar')[0].style.setProperty('left', event.data.left);
		$('.bar')[0].style.setProperty('width', (event.data.width / (event.data.fuel / 100)));
		$('.shadow')[0].style.setProperty('bottom', event.data.bottom);
		$('.shadow')[0].style.setProperty('left', event.data.left);
		$('.shadow')[0].style.setProperty('width', event.data.width);
		$('.bar').show();
		$('.shadow').show();

	} else if (event.data.action == 'hide') {
		$('.bar').hide();
		$('.shadow').hide();
	}
});