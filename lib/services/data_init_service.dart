import '../models/models.dart';
import '../services/services.dart';

class DataInitService {
  // Initialize sample data
  static Future<void> initializeSampleData() async {
    try {
      print('🔥 Bắt đầu khởi tạo dữ liệu mẫu...');
      
      // Check if data already exists
      print('Kiểm tra dữ liệu hiện có...');
      final existingMovies = await MovieService.getAllMovies();
      final existingCategories = await CategoryService.getAllCategories();
      
      if (existingMovies.isNotEmpty && existingCategories.isNotEmpty) {
        print('Dữ liệu đã tồn tại: ${existingMovies.length} movies, ${existingCategories.length} categories');
        return;
      }
      
      // Create default categories
      if (existingCategories.isEmpty) {
        print('Tạo categories...');
        await CategoryService.createDefaultCategories();
        print('Categories created');
      }
      
      // Create sample movies if none exist
      if (existingMovies.isEmpty) {
        print('Tạo movies...');
        await _createSampleMovies();
        print('Movies created');
      }
      
      print('Sample data initialized successfully');
    } catch (e) {
      print('Error initializing sample data: $e');
      rethrow; // Re-throw để UI có thể catch
    }
  }

  static Future<void> _createSampleMovies() async {
    try {
      print('Kiểm tra movies hiện có...');
      // Check if movies already exist
      List<MovieModel> existingMovies = await MovieService.getAllMovies();
      if (existingMovies.isNotEmpty) {
        print('Movies đã tồn tại: ${existingMovies.length} phim');
        return; // Movies already exist
      }

      print('Tạo danh sách movies mẫu...');
      List<Map<String, dynamic>> sampleMovies = [
        // MARVEL & SUPERHERO MOVIES
        {
          'title': 'Avengers: Endgame',
          'description': 'Sau sự kiện tàn khốc của Infinity War, vũ trụ đang trong tình trạng hỗn loạn. Với sự giúp đỡ của những đồng minh còn lại, các Avengers tập hợp một lần nữa để đảo ngược hành động của Thanos và khôi phục lại trật tự cho vũ trụ.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/or06FN3Dka5tukK1e9sl16pB3iy.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/7RyHsO4yDXtBv1zUU3mTpHeQ0d5.jpg',
          'releaseYear': 2019,
          'duration': 181,
          'rating': 4.8,
          'genres': ['Action', 'Sci-Fi', 'Adventure'],
          'cast': ['Robert Downey Jr.', 'Chris Evans', 'Mark Ruffalo', 'Chris Hemsworth'],
          'director': 'Anthony Russo, Joe Russo',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 15000,
        },
        {
          'title': 'Spider-Man: No Way Home',
          'description': 'Peter Parker gặp phải rắc rối lớn khi danh tính của mình bị lộ. Anh tìm đến Doctor Strange để xin giúp đỡ, nhưng phép thuật đã mở ra cánh cửa đa vũ trụ nguy hiểm.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/1g0dhYtq4irTY1GPXvft6k4YLjm.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/14QbnygCuTO0vl7CAFmtRkgaVBh.jpg',
          'releaseYear': 2021,
          'duration': 148,
          'rating': 4.7,
          'genres': ['Action', 'Sci-Fi', 'Adventure'],
          'cast': ['Tom Holland', 'Zendaya', 'Benedict Cumberbatch'],
          'director': 'Jon Watts',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 12000,
        },
        {
          'title': 'The Batman',
          'description': 'Bruce Wayne bắt đầu hành trình trở thành Batman, đối mặt với Riddler và khám phá sự tham nhũng trong thành phố Gotham.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/b0PlHlV5tI5DMy6rxH9Kd2BeTCv.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/KeW39YuXx8bkjmh5lJ2KaNk9wgp.jpg',
          'releaseYear': 2022,
          'duration': 176,
          'rating': 4.5,
          'genres': ['Action', 'Crime', 'Drama'],
          'cast': ['Robert Pattinson', 'Zoë Kravitz', 'Paul Dano'],
          'director': 'Matt Reeves',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 9800,
        },
        {
          'title': 'Black Panther',
          'description': 'T\'Challa trở về quê hương Wakanda để trở thành vua, nhưng phải đối mặt với kẻ thù cũ và quyết định tương lai của đất nước.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/uxzzxijgPIY7slzFvMotPv8wjKA.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/b6ZJZHUdMEFECvGiDpJjlfUWela.jpg',
          'releaseYear': 2018,
          'duration': 134,
          'rating': 4.6,
          'genres': ['Action', 'Adventure', 'Sci-Fi'],
          'cast': ['Chadwick Boseman', 'Michael B. Jordan', 'Lupita Nyong\'o'],
          'director': 'Ryan Coogler',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 11200,
        },

        // ACTION & THRILLER
        {
          'title': 'John Wick: Chapter 4',
          'description': 'John Wick khám phá con đường đến chiến thắng chống lại High Table. Nhưng trước khi anh có thể kiếm được tự do, John phải đối mặt với kẻ thù mới.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/vYk5HJpYj6IuJJUTKlXAocnPdKP.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/fOy2Jurz9k6RnJnMUMRDAgBwru2.jpg',
          'releaseYear': 2023,
          'duration': 169,
          'rating': 4.7,
          'genres': ['Action', 'Thriller', 'Crime'],
          'cast': ['Keanu Reeves', 'Donnie Yen', 'Bill Skarsgård'],
          'director': 'Chad Stahelski',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'R',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 8900,
        },
        {
          'title': 'Top Gun: Maverick',
          'description': 'Maverick trở lại sau hơn 30 năm phục vụ như một phi công thử nghiệm hàng đầu của Hải quân, tránh thăng chức và đối mặt với quá khứ.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/62HCnUTziyWcpDaBO2i1DX17ljH.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/odJ4hx6g6vBt4lBWKFD1tI8WS4x.jpg',
          'releaseYear': 2022,
          'duration': 130,
          'rating': 4.8,
          'genres': ['Action', 'Drama', 'Adventure'],
          'cast': ['Tom Cruise', 'Miles Teller', 'Jennifer Connelly'],
          'director': 'Joseph Kosinski',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 13500,
        },
        {
          'title': 'Mission: Impossible - Dead Reckoning',
          'description': 'Ethan Hunt và team IMF phải đối mặt với mối đe dọa mới nguy hiểm nhất từng có - một vũ khí khủng khiếp có thể hủy diệt nhân loại.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/NNxYkU70HPurnNCSiCjYAmacwm.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/yF1eOkaYvwiORauRCPWznV9xVvi.jpg',
          'releaseYear': 2023,
          'duration': 163,
          'rating': 4.6,
          'genres': ['Action', 'Thriller', 'Adventure'],
          'cast': ['Tom Cruise', 'Hayley Atwell', 'Ving Rhames'],
          'director': 'Christopher McQuarrie',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 7800,
        },

        // SCI-FI & FANTASY
        {
          'title': 'Dune',
          'description': 'Paul Atreides, một chàng trai xuất sắc và tài năng sinh ra để làm những điều vĩ đại vượt quá sự hiểu biết của anh, phải du hành đến hành tinh nguy hiểm nhất trong vũ trụ.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/d5NXSklXo0qyIYkgV94XAgMIckC.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/iopYFB1b6Bh7FWZh3onQhph1sih.jpg',
          'releaseYear': 2021,
          'duration': 155,
          'rating': 4.5,
          'genres': ['Sci-Fi', 'Adventure', 'Drama'],
          'cast': ['Timothée Chalamet', 'Rebecca Ferguson', 'Oscar Isaac'],
          'director': 'Denis Villeneuve',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 9500,
        },
        {
          'title': 'Avatar: The Way of Water',
          'description': 'Jake Sully sống với gia đình mới trên hành tinh Pandora. Khi một mối đe dọa quen thuộc trở lại, Jake phải làm việc với Neytiri để bảo vệ hành tinh của họ.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/s16H6tpK2utvwDtzZ8Qy4qm5Emw.jpg',
          'releaseYear': 2022,
          'duration': 192,
          'rating': 4.4,
          'genres': ['Sci-Fi', 'Adventure', 'Action'],
          'cast': ['Sam Worthington', 'Zoe Saldana', 'Sigourney Weaver'],
          'director': 'James Cameron',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG-13',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 14200,
        },

        // HORROR
        {
          'title': 'Scream VI',
          'description': 'Những vụ giết người Ghostface mới bắt đầu, với chị em Carpenter là mục tiêu. Họ phải để lại Woodsboro và bắt đầu một chương mới ở New York.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/wDWwtvkRRlgTiUr6TyLSMX8FCuZ.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/b9UCfDzwiWw7mIFsIQR9ZJUeh7q.jpg',
          'releaseYear': 2023,
          'duration': 122,
          'rating': 4.2,
          'genres': ['Horror', 'Thriller', 'Crime'],
          'cast': ['Melissa Barrera', 'Jenna Ortega', 'Courteney Cox'],
          'director': 'Matt Bettinelli-Olpin, Tyler Gillett',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'R',
          'quality': 'HD',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 6700,
        },
        {
          'title': 'The Nun II',
          'description': 'Năm 1956, một linh mục bị giết một cách bí ẩn và cái ác lan rộng. Sister Irene lại đối mặt với Valak, ác quỷ nữ tu.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/5gzzkR7y3hnY8AD1wXjCnVlHba5.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/53z2fXEKfnNg2uSOPss2unPBGX1.jpg',
          'releaseYear': 2023,
          'duration': 110,
          'rating': 3.8,
          'genres': ['Horror', 'Thriller'],
          'cast': ['Taissa Farmiga', 'Jonas Bloquet', 'Storm Reid'],
          'director': 'Michael Chaves',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'R',
          'quality': 'HD',
          'isFeatured': false,
          'isPopular': false,
          'viewCount': 5200,
        },

        // ANIMATION
        {
          'title': 'Spider-Man: Into the Spider-Verse',
          'description': 'Miles Morales trở thành Spider-Man và gặp gỡ các Spider-People khác từ những chiều không gian khác nhau.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/iiZZdoQBEYBv6id8su7ImL0oCbD.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/7d6EY00g1c39SGZOoCJ5Py9nNth.jpg',
          'releaseYear': 2018,
          'duration': 117,
          'rating': 4.9,
          'genres': ['Animation', 'Action', 'Adventure'],
          'cast': ['Shameik Moore', 'Jake Johnson', 'Hailee Steinfeld'],
          'director': 'Bob Persichetti, Peter Ramsey',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 10500,
        },
        {
          'title': 'Turning Red',
          'description': 'Mei Lee, một cô gái 13 tuổi tự tin, bị chia rẽ giữa việc là một đứa con ngoan của mẹ và sự hỗn loạn của tuổi teen.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/qsdjk9oAKSQMWs0Vt5Pyfh6O4GZ.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/x747ZvF0CcYYTTlOmRlbcQ18JRK.jpg',
          'releaseYear': 2022,
          'duration': 100,
          'rating': 4.1,
          'genres': ['Animation', 'Comedy', 'Family'],
          'cast': ['Rosalie Chiang', 'Sandra Oh', 'Ava Morse'],
          'director': 'Domee Shi',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG',
          'quality': 'HD',
          'isFeatured': false,
          'isPopular': false,
          'viewCount': 7100,
        },

        // VIETNAMESE MOVIES
        {
          'title': 'Cô Ba Sài Gòn',
          'description': 'Câu chuyện tình yêu và cuộc sống của cô Ba - một thợ may tài hoa ở Sài Gòn những năm 1960.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/vVHA9dJJPDMClGBToyU3yJ5SL4j.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/zQ3RqJq5h1gHRNb1SZJf6IbKRy.jpg',
          'releaseYear': 2017,
          'duration': 98,
          'rating': 4.3,
          'genres': ['Romance', 'Drama'],
          'cast': ['Ninh Dương Lan Ngọc', 'S.T Sơn Thạch', 'Diệu Nhi'],
          'director': 'Kay Nguyễn',
          'country': 'Vietnam',
          'language': 'Vietnamese',
          'ageRating': 'T16',
          'quality': 'HD',
          'isFeatured': true,
          'isPopular': false,
          'viewCount': 6500,
        },
        {
          'title': 'Mắt Biếc',
          'description': 'Chuyện tình yêu đầu của Ngạn dành cho Hà Lan, từ thời thơ ấu đến khi trưởng thành, dựa trên tiểu thuyết của Nguyễn Nhật Ánh.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/jTFqaKhbAi1m9E0QQvhMkXj2iCj.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/tAlKAY83VLCqFNyS1hoNWo1kA8a.jpg',
          'releaseYear': 2019,
          'duration': 117,
          'rating': 4.1,
          'genres': ['Romance', 'Drama'],
          'cast': ['Trần Nghĩa', 'Trúc Anh', 'Phan Ngọc Luân'],
          'director': 'Victor Vũ',
          'country': 'Vietnam',
          'language': 'Vietnamese',
          'ageRating': 'T13',
          'quality': 'HD',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 7200,
        },
        {
          'title': 'Tết Ở Làng Địa Ngục',
          'description': 'Bộ phim hài Việt Nam kể về chuyến về quê ăn Tết đầy rắc rối của một gia đình sống ở thành phố.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/aIB5VkZ1HJfhN1LFJkdTrQnJiJp.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/nEpR4nwY8R9HWhfBQ5pHY3aBDWS.jpg',
          'releaseYear': 2021,
          'duration': 110,
          'rating': 4.2,
          'genres': ['Comedy', 'Family'],
          'cast': ['Tuấn Trần', 'Thu Trang', 'Tiến Luật'],
          'director': 'Đinh Tuấn Vũ',
          'country': 'Vietnam',
          'language': 'Vietnamese',
          'ageRating': 'T13',
          'quality': 'HD',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 8500,
        },
        {
          'title': 'Hai Phượng',
          'description': 'Một người mẹ đơn thân sống ở vùng nông thôn phải chiến đấu để cứu con gái khỏi băng nhóm buôn người.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/kN36dSAmTFJiw9jAKE2G2LsBXHm.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/aL5kCPEL5p2QcfgqjnZJLKgOUtT.jpg',
          'releaseYear': 2019,
          'duration': 98,
          'rating': 4.0,
          'genres': ['Action', 'Thriller'],
          'cast': ['Ngô Thanh Vân', 'Mai Cát Vi', 'Lâm Thanh Mỹ'],
          'director': 'Lê Văn Kiệt',
          'country': 'Vietnam',
          'language': 'Vietnamese',
          'ageRating': 'T18',
          'quality': 'HD',
          'isFeatured': false,
          'isPopular': false,
          'viewCount': 5800,
        },

        // COMEDY
        {
          'title': 'The Super Mario Bros. Movie',
          'description': 'Mario và Luigi, hai anh em thợ sửa ống nước, được đưa đến vương quốc Mushroom nơi họ phải cứu Công chúa Peach khỏi Bowser.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/qNBAXBIQlnOThrVvA6mA2B5ggV6.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/nLBRD7UPR6GjmWQp6ASAfCTaWKX.jpg',
          'releaseYear': 2023,
          'duration': 92,
          'rating': 4.3,
          'genres': ['Animation', 'Comedy', 'Family'],
          'cast': ['Chris Pratt', 'Anya Taylor-Joy', 'Charlie Day'],
          'director': 'Aaron Horvath, Michael Jelenic',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 11800,
        },

        // DRAMA
        {
          'title': 'Everything Everywhere All at Once',
          'description': 'Một người phụ nữ trung niên bị cuốn vào một cuộc phiêu lưu điên rồ qua đa vũ trụ khi vũ trụ bị đe dọa.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/w3LxiVYdWWRvEVdn5RYq6jIqkb1.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/yF1eOkaYvwiORauRCPWznV9xVvi.jpg',
          'releaseYear': 2022,
          'duration': 139,
          'rating': 4.7,
          'genres': ['Drama', 'Sci-Fi', 'Comedy'],
          'cast': ['Michelle Yeoh', 'Stephanie Hsu', 'Ke Huy Quan'],
          'director': 'Daniels',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'R',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 8700,
        },

        // RECENT RELEASES 2024
        {
          'title': 'Deadpool & Wolverine',
          'description': 'Wade Wilson được TVA tuyển dụng cho một nhiệm vụ có thể thay đổi lịch sử MCU. Anh phải thuyết phục Wolverine để cứu vũ trụ của mình.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/8cdWjvZQUExUUTzyp4t6EDMubfO.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/yDHYTfA3R0jFYba16jBB1ef8oIt.jpg',
          'releaseYear': 2024,
          'duration': 127,
          'rating': 4.8,
          'genres': ['Action', 'Comedy', 'Sci-Fi'],
          'cast': ['Ryan Reynolds', 'Hugh Jackman', 'Emma Corrin'],
          'director': 'Shawn Levy',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'R',
          'quality': '4K',
          'isFeatured': true,
          'isPopular': true,
          'viewCount': 16500,
        },
        {
          'title': 'Inside Out 2',
          'description': 'Riley bước vào tuổi teen và những cảm xúc mới xuất hiện trong trụ sở, tạo ra sự hỗn loạn trong tâm trí cô bé.',
          'posterUrl': 'https://image.tmdb.org/t/p/w500/vpnVM9B6NMmQpWeZvzLvDESb2QY.jpg',
          'backdropUrl': 'https://image.tmdb.org/t/p/original/stKGOm8UyhuLPR9sZLjs5AkmncA.jpg',
          'releaseYear': 2024,
          'duration': 96,
          'rating': 4.6,
          'genres': ['Animation', 'Family', 'Comedy'],
          'cast': ['Amy Poehler', 'Maya Hawke', 'Kensington Tallman'],
          'director': 'Kelsey Mann',
          'country': 'USA',
          'language': 'English',
          'ageRating': 'PG',
          'quality': '4K',
          'isFeatured': false,
          'isPopular': true,
          'viewCount': 13200,
        },
      ];

      // Create movies
      for (Map<String, dynamic> movieData in sampleMovies) {
        MovieModel movie = MovieModel(
          title: movieData['title'],
          description: movieData['description'],
          posterUrl: movieData['posterUrl'],
          backdropUrl: movieData['backdropUrl'],
          releaseYear: movieData['releaseYear'],
          duration: movieData['duration'],
          rating: movieData['rating'].toDouble(),
          genres: List<String>.from(movieData['genres']),
          cast: List<String>.from(movieData['cast']),
          director: movieData['director'],
          country: movieData['country'],
          language: movieData['language'],
          ageRating: movieData['ageRating'],
          quality: movieData['quality'],
          isFeatured: movieData['isFeatured'],
          isPopular: movieData['isPopular'],
          viewCount: movieData['viewCount'],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await FirebaseService.moviesCollection.add(movie.toFirestore());
      }

      print('Sample movies created successfully');
    } catch (e) {
      print('Error creating sample movies: $e');
    }
  }

  // Initialize user data after signup
  static Future<void> initializeUserData(String userId) async {
    try {
      // Create default playlists
      await PlaylistService.createDefaultPlaylists(userId);
      
      print('User data initialized for: $userId');
    } catch (e) {
      print('Error initializing user data: $e');
    }
  }

  // Create sample reviews for testing
  static Future<void> createSampleReviews(String userId) async {
    try {
      List<MovieModel> movies = await MovieService.getAllMovies();
      if (movies.isEmpty) return;

      // Create a few sample reviews
      List<Map<String, dynamic>> sampleReviews = [
        {
          'movieId': movies[0].id,
          'rating': 5.0,
          'comment': 'Great movie! Best movie of the year.',
          'isRecommended': true,
        },
        {
          'movieId': movies[1].id,
          'rating': 4.0,
          'comment': 'Good movie, good actors.',
          'isRecommended': true,
        },
      ];

      for (Map<String, dynamic> reviewData in sampleReviews) {
        if (reviewData['movieId'] != null) {
          ReviewModel review = ReviewModel(
            userId: userId,
            movieId: reviewData['movieId'],
            rating: reviewData['rating'].toDouble(),
            comment: reviewData['comment'],
            isRecommended: reviewData['isRecommended'],
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

          await ReviewService.addReview(review);
        }
      }

      print('Sample reviews created');
    } catch (e) {
      print('Error creating sample reviews: $e');
    }
  }
}
