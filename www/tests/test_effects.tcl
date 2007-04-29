set fadescript [ah::effects -element "test" \
				-effect "Fade" \
				-options "duration:2.0,afterFinish:function() { alert('element is gone'); }" ]
set showscript [ah::effects -element "test" \
				-effect "Appear" \
				-options "duration:2.0,afterFinish:function() { alert('element has appeared'); }" ]