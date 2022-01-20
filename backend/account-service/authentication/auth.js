function authorize(req, res, next) {
    if (req.user) {
        next();
    } else {
       res.statusCode = 401;
       res.send();
    }
}

function getUserId(req) {
    if (req.user) {
        return req.user.uid;
    }

    return false;
}

module.exports = {
    authorize,
    getUserId
}