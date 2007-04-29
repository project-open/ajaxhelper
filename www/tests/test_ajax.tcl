set updatescript [ah::ajaxupdate -container "test" \
				-url "test_ajax-handle" \
				-pars "'myname='+document.getElementById('name').value" \
				-options "onSuccess:function(t){ alert('update done : '+t.responseText); }"]
