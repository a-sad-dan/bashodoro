#!/usr/bin/awk -f
BEGIN {
    FS=",";

    printf "\n🗓 Today's Stats:\n\n";
    print "----------------------------------------------------------------------------------------------------------------------";
}

function format_time(sec) {
    h = int(sec / 3600);
    m = int((sec % 3600) / 60);
    s = sec % 60;
    return sprintf("%02dh %02dm %02ds", h, m, s);
}

NR > 1 && tolower($1) == "today" {
    pomo_time = format_time($3);
    short_break_time = format_time($4);
    long_break_time = format_time($5);
    split($2, parts, " to ");
    gsub(/ 00:00:00/, "", parts[1]);
    gsub(/ 00:00:00/, "", parts[2]);
    clean_range = parts[1] " to " parts[2];

    printf "Date Range: %s\nPomo Time: %s\nShort Break: %s\nLong Break: %s\nPInt: %s\nSBInt: %s\nLBInt: %s\n", clean_range, pomo_time, short_break_time, long_break_time, $6, $7, $8;
}