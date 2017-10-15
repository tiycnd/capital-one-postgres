import groovy.sql.Sql

@GrabConfig(systemClassLoader=true)
@Grab(group='org.postgresql', module='postgresql', version='42.1.4')

def env = System.getenv()
def dbUrl = "jdbc:postgresql://localhost/movies"
def dbUser = System.properties['db.user']
def dbPassword = System.properties['db.password']
def dbDriver = "org.postgresql.Driver"

def sql = Sql.newInstance(dbUrl, dbUser, dbPassword, dbDriver)
def random = new Random()

def movieIds = sql.rows('SELECT id FROM movies').collect { row -> row.id }
def insertReviewSql = 'INSERT INTO reviews (reviewer_id, movie_id, score) VALUES (?, ?, ?)'

def numReviewers = 0
sql.eachRow('SELECT id FROM reviewers') { row -> 
  def reviewerId = row.id
  def numOfReviews = (random.nextGaussian() * 3 + 10).toInteger()
  if (numOfReviews < 1) {
    numOfReviews = 1
  }
  def reviewerAverage = (random.nextGaussian() + 3)
  numReviewers++
  // println("$numReviewers $numOfReviews $reviewerAverage")

  Collections.shuffle(movieIds)

  sql.withBatch(numOfReviews, insertReviewSql) { ps ->
    movieIds.take(numOfReviews).each { movieId ->     
      def score = (random.nextGaussian() + reviewerAverage).round()
      if (score < 1) {
        score = 1
      }
      if (score > 5) {
        score = 5
      }
      ps.addBatch(reviewerId, movieId, score)
    }
  }
}

