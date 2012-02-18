ERL=erl
APP=genesis

all:
	$(ERL) -pa /Users/jack/Codes/ChicagoBoss-0.6.10/ebin -eval 'boss_load:load_all_modules_and_emit_app_file($(APP), "ebin")' -s init stop -noshell

clean:
	rm -fv ebin/*.beam
	rm -fv ebin/$(APP).app
	
update_po:
	$(ERL) -pa ebin -pa ../ChicagoBoss/ebin -eval 'boss_load:load_models("ebin")' -eval 'boss_lang:update_po()' -s init stop -noshell

.PHONY: test
test:
	#$(ERL) -pa $(PWD)/ebin -pa /Users/jack/Codes/ChicagoBoss-0.6.10/ebin -run boss_web_test start $(APP) -noshell
	$(ERL) -pa $(PWD)/ebin -eval 'agent:test()' -s init stop -noshell
