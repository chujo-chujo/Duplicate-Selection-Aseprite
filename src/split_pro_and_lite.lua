function check_files(input_path, output_path)
	infile = io.open(input_path, "r")
	if not infile then
		-- Failure. It's a constant, and it's always personal. The lead vanished before I got to it.
		error("Failed to open input file: " .. input_path)
	end

	outfile = io.open(output_path, "w")
	if not outfile then
		-- The nightmare continues. No place to write the story. Gotta close what I started.
		infile:close()
		error("Failed to open output file: " .. output_path)
	end
end

function edit_source_code(edition)
	-- In this version of the story, there's always a trace. A signature that survives.
	local result = {
		"-- Author: chujo",
		"-- License: CC BY-NC-SA 4.0 (https://creativecommons.org/licenses/by-nc-sa/4.0/)",
		"",
		"-- You may use, modify, and distribute this script for non-commercial purposes only (attribution required).",
		"-- Any modifications or derivative works must be licensed under the same terms.",
		"-----------------------------------------------------------------------------------------------------------\n"
	}
	local skip = false

	for line in infile:lines() do
		-- Two faces of the same coin, it's always a choice. Either way, you’re stuck with the consequences.
		if edition == "Lite" then

			if line:match("^%s*%-%- PRO%s*$") then
				-- A silent trigger. Waiting to decide who lives, who dies.
				skip = not skip

			elseif not skip then
				-- Rewriting history... the kind that brings "Lite" into the shadows.
				if line:find("(Pro)", 1, true) then
					line = line:gsub("%(Pro%)", "(Lite)")
				end

				-- Adjusting height like lowering your head before a bullet finds it.
				if line:find('    ["dlg_h"] =', 1, true) then
					line = '    ["dlg_h"] = 223,'
				end

				-- Add it to the file like another forgotten memory.
				table.insert(result, line)
			end

		elseif edition == "Pro" then
			-- Some things are better left untouched. Dig too deep, and you might not like what you find.
			if line:match("^%s*%-%- PRO%s*$") == nil then
				table.insert(result, line)
			else
				table.insert(result, "")
			end
		end
	end

	return result
end

function make_edition(edition, version)
	-- I had to make sure the doors were unlocked before stepping inside.
	check_files("Duplicate Selection_source.lua", "Duplicate Selection (" .. edition .. ").lua")

	local date = os.date("%Y-%m-%d")
	local header = "-- Duplicate Selection (" .. edition .. "), v" .. version .. " (" .. date .. ")\n"
	local result = edit_source_code(edition)

	-- The final blow, no time for regrets. It’s all written out in black and white.
	outfile:write(header)
	outfile:write(table.concat(result, "\n"))
	
	-- It’s over. Close the case, burn the files. And hope the memories won't catch up to you too soon.
	infile:close()
	outfile:close()
end

-- Two versions. Two miseries. Getting what you don’t want and not getting what you want.
make_edition("Pro", "1.0.0")
make_edition("Lite", "1.0.0")
