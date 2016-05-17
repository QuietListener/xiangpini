#encoding:utf-8
require "httpclient"

desc "添加单词"
task :add_words  => :environment do
  Rails.application.eager_load!
  path = "#{Rails.root}/doc/all_words.txt"
  puts "path:#{path}"

  File.open(path).each_with_index  do |line,index|
    word = line.strip
    next if word.blank?

    w = Word.where("word = ?",word).first
    next if w

    #添加数据
    w = Word.new
    w.word = word
    w.save
    puts "#{index}:add word:#{word}"
  end
end

desc "抓取海词的网页"
task :grab_html  => :environment do
  Rails.application.eager_load!

  baseUrl = "http://dict.cn/"

  ws = Word.find_by_sql("select words.* from words where id  not in(select word_id from word_htmls )")
  ws.each do |w|
    retrycount = 0

    word = w.word
    url = URI.encode("#{baseUrl}#{word.strip}")
    wh = WordHtml.new
    wh.word_id=w.id
    begin
      res =response = RestClient.get url
      wh.html_haici=res.to_str
      wh.status_haici=res.code.to_i
      wh.save
      puts "fetch :#{url} ; status:#{res.code}"
    rescue Exception=>e
      puts "error:"+e.message
      puts e.backtrace.join("\r\n")
      sleep(2)
      if retrycount < 3
        retrycount+=1
        puts "retry #{url}"
        retry
      end
    ensure
      if wh.id.blank?
         wh.save
      end
    end

    sleep(1)
  end
end