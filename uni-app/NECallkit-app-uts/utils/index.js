export function secToTime(time) {
    let timeStr = null;
    let hour = 0;
    let minute = 0;
    let second = 0;
    
    if (time <= 0) return "00:00";
    else {
        minute = Math.floor(time / 60);
        if (minute < 60) {
            second = time % 60;
            timeStr = unitFormat(minute) + ":" + unitFormat(second);
        } else {
            hour = Math.floor(minute / 60);
            if (hour > 99) return "99:59:59";
            minute = minute % 60;
            second = time - hour * 3600 - minute * 60;
            timeStr = unitFormat(hour) + ":" + unitFormat(minute) + ":" + unitFormat(second);
        }
    }
    return timeStr;
}

function unitFormat(num) {
    return num < 10 ? "0" + num : num.toString();
}