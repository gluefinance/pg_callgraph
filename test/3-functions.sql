-- Various test functions to generate some data activity
CREATE OR REPLACE FUNCTION new_user(_username text, _password text) RETURNS INTEGER AS $$
DECLARE
_user_id integer;
BEGIN
    INSERT INTO users (name,password) VALUES (_username,_password) RETURNING user_id INTO STRICT _user_id;
    RETURN _user_id;
END;
$$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION have_user(_username text) RETURNS BOOLEAN AS $$
DECLARE
BEGIN
    PERFORM 1 FROM users WHERE name = _username;
    IF FOUND THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION check_password(_username text, _password text) RETURNS INTEGER AS $$
DECLARE
_user_id integer;
BEGIN
    SELECT user_id INTO _user_id FROM users WHERE name = _username AND password = _password;
    IF NOT FOUND THEN
        RAISE EXCEPTION 'invalid username or password';
    END IF;
    RETURN _user_id;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION get_user_id(_username text, _password text) RETURNS INTEGER AS $$
DECLARE
_user_id integer;
BEGIN
    IF have_user(_username) THEN
        _user_id := check_password(_username, _password);
    ELSE
        _user_id := new_user(_username, _password);
    END IF;
    RETURN _user_id;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION new_account_id(_user_id integer, _currency char(3)) RETURNS INTEGER AS $$
DECLARE
_account_id integer;
BEGIN
    INSERT INTO accounts (user_id,currency) VALUES (_user_id,_currency) RETURNING account_id INTO STRICT _account_id;
    RETURN _account_id;
END;
$$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION get_account_id(_user_id integer, _currency char(3)) RETURNS INTEGER AS $$
DECLARE
_account_id integer;
BEGIN
    SELECT account_id INTO _account_id FROM accounts WHERE user_id = _user_id AND currency = _currency;
    IF NOT FOUND THEN
        _account_id := new_account_id(_user_id, _currency);
    END IF;
    RETURN _account_id;
END;
$$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION get_account_balance(_username text, _password text, _currency char(3)) RETURNS NUMERIC AS $$
DECLARE
_user_id integer;
_account_id integer;
_balance numeric;
BEGIN
    _user_id := get_user_id(_username, _password);
    _account_id := get_account_id(_user_id, _currency);
    SELECT balance INTO _balance FROM accounts WHERE account_id = _account_id;
    IF NOT FOUND THEN
        RETURN 0;
    END IF;
    RETURN _balance;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION update_account_balance(_user_id integer, _currency char(3), _amount numeric) RETURNS NUMERIC AS $$
DECLARE
_account_id integer;
_balance numeric;
BEGIN
    _account_id := get_account_id(_user_id, _currency);
    UPDATE accounts SET balance = balance + _amount WHERE account_id = _account_id RETURNING balance INTO STRICT _balance;
    RETURN _balance;
END;
$$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION new_transaction(_username text, _password text, _currency char(3), _amount numeric) RETURNS INTEGER AS $$
DECLARE
_user_id        integer;
_balance        integer;
_account_id     integer;
_transaction_id integer;
BEGIN
    _user_id    := get_user_id(_username, _password);
    _account_id := get_account_id(_user_id, _currency);
    _balance    := update_account_balance(_user_id, _currency, _amount);
    INSERT INTO transactions (user_id, account_id, amount, balance) VALUES (_user_id, _account_id, _amount, _balance) RETURNING transaction_id INTO STRICT _transaction_id;
    RETURN _transaction_id;
END;
$$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION a() RETURNS BOOLEAN AS $BODY$
DECLARE
BEGIN
PERFORM ab();
PERFORM ac();
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION ab() RETURNS BOOLEAN AS $BODY$
DECLARE
BEGIN
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION ac() RETURNS BOOLEAN AS $BODY$
DECLARE
BEGIN
PERFORM aca();
PERFORM acb();
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION aca() RETURNS BOOLEAN AS $BODY$
DECLARE
BEGIN
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;


CREATE OR REPLACE FUNCTION acb() RETURNS BOOLEAN AS $BODY$
DECLARE
BEGIN
RETURN TRUE;
END;
$BODY$ LANGUAGE plpgsql VOLATILE;
