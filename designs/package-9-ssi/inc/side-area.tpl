<div class="side-area">
	<form action="#" class="form">
		<fieldset class="inputs">
			<legend>
				<span>Section Name</span>
			</legend>
			<ol class="form-items-h">
				<li class="string optional name">
					<label for="user_name">Event name:</label>
					<div class="input-bg-alt">
						<input id="user_name" maxlength="48" class="input-text" name="user[name]" size="40" type="text" />
					</div>
				</li>
				<li class="select optional">
					<label>Event type:</label>
					<select name="">
						<option value="">&nbsp;</option>
						<option value="1">1</option>
						<option value="2">2</option>
						<option value="3">3</option>
						<option value="4">4</option>
					</select>
				</li>
				<li class="select optional">
					<label >Date:</label>
					<select class="middle">
						<option value="1" selected="selected">Feb</option>
						<option value="2">2</option>
						<option value="3">3</option>
						<option value="4">4</option>
					</select>
					<select class="short">
						<option value="1" selected="selected">29</option>
						<option value="2">&nbsp;</option>
						<option value="3">&nbsp;</option>
						<option value="4">&nbsp;</option>
					</select>
					<select class="middle-alt">
						<option value="1" selected="selected">2009</option>
						<option value="2">&nbsp;</option>
						<option value="3">&nbsp;</option>
						<option value="4">&nbsp;</option>
					</select>
					<a href="#" class="calendar">calendar</a>
				</li>
				<li class="select optional">
					<label>Time:</label>
					<select class="short marg">
						<option value="1" selected="selected">18</option>
						<option value="2">&nbsp;</option>
						<option value="3">&nbsp;</option>
						<option value="4">&nbsp;</option>
					</select>
					<select class="short">
						<option value="1" selected="selected">00</option>
						<option value="2">&nbsp;</option>
						<option value="3">&nbsp;</option>
						<option value="4">&nbsp;</option>
					</select>
					<div class="f-row"><a href="#" class="add-link">Add End date &amp; Time</a></div>
				</li>
				<li class="string optional name">
					<label>Location:</label>
					<div class="input-bg-alt">
						<input maxlength="48" class="input-text" name="" size="40" type="text" />
					</div>
				</li>
				<li class="string optional name">
					<label>Address:</label>
					<div class="input-bg-alt">
						<input maxlength="48" class="input-text" name="" size="40" type="text" />
					</div>
					<div class="check-h">
						<input class="input-check" id="map" type="checkbox" />
						<label for="map">Add Map</label>
					</div>
					<div class="divider">&nbsp;</div>
				</li>
				<li class="string optional name">
					<label>Host Name:</label>
					<div class="input-bg-alt input-text-middle">
						<input maxlength="48" class="input-text input-text-middle" name="" size="30" type="text" />
					</div>
					<span class="note">(one name only)</span>
					<div class="f-row"><a href="#" class="add-link">Add Host</a></div>
					<div class="divider">&nbsp;</div>
				</li>
				<li class="text optional custom_value">
					<label>Message to Guests:</label>
					<div class="textarea-bg"><textarea cols="50" name="" rows="9"></textarea></div>
					<span class="note"> (Maximum 345 Notes)</span>
				</li>
			</ol>
		</fieldset>
	</form>
</div>