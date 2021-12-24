var express = require('express')
var postsService = require("./services/posts-service");
var router = express.Router()

const bodyParser = require("body-parser")
const jsonParser = bodyParser.json();

// middleware that is specific to this router
router.use(function timeLog (req, res, next) {
  next()
})

/**
 * @swagger
 * /posts:
 *   post:
 *     summary: Create a JSONPlaceholder user.
 *     description: Create new post
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *                     title:
 *                       type: string
 *                       description: Title of the post.
 *                       example: "Sample title"
 *                     description:
 *                       type: string
 *                       description: Description of the post.
 *                       example: Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
 *     responses:
 *       201:
 *         description: Created
 *         content:
 *           application/json:
 *             schema:
 *               type: object
 *               properties:
 *                 data:
 *                   type: object
 *                   properties:
 *                     title:
 *                       type: string
 *                       description: Title of the post.
 *                       example: "Sample title"
 *                     description:
 *                       type: string
 *                       description: Description of the post.
 *                       example: Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
*/
router.post('/', jsonParser, function (req, res) {
    let post = {
      title: req.body.title,
      description: req.body.description,
    }
    res.send(postsService.create(post))
  })

/**
 * @swagger
 * /posts:
 *      get:
 *          description: Get all posts
 *          responses:
 *              "200":
 *                  description: List of the posts
 *                  content:
 *                      application/json:
 *                          schema:
 *                              type: object
 *                              properties:
 *                              data:
 *                                  type: object
 *                                  properties:
 *                                      title:
 *                                          type: string
 *                                          description: Title of the post.
 *                                          example: "Sample title"
 *                                      description:
 *                                          type: string
 *                                          description: Description of the post.
 *                                          example: Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
 */
router.get('/', async (req, res) => {
  let posts = await postsService.getAll();
  res.send(posts)
})

router.get('/top', function (req, res) {
  res.send(postsService.get(1))
})

module.exports = router