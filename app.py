from flask import Flask, render_template,request,redirect,url_for,jsonify
import mysql.connector

app=Flask(__name__,template_folder='templates')
my_sql = mysql.connector.connect(
    host="localhost",
    user="root",
    password="",
    database="apartman_sitesi"
)

class kisi:
    def __init__(self, username, password, user_type, full_name, email, apartment):
        self.username = username
        self.password = password
        self.user_type = user_type
        self.full_name = full_name
        self.email = email
        self.apartment = apartment

@app.route("/")
def ana():
    return render_template('ana_ekran.html')


@app.route("/sakin", methods=['GET', 'POST'])
def sakin():
    cursor = my_sql.cursor()
    if request.method == 'POST':
        isim = request.form['username']
        sifre = request.form['password']
        cursor.execute(
            "select Sifre from apartman_sitesi.Kullanicilar where Kullanicilar.KullaniciAdi='{}';".format(isim))
        kullanıcı = cursor.fetchone()
        if sifre == kullanıcı[0]:
            return redirect(url_for('login', isim=isim))
        else:
            return "Yanlış kullanıcı adı veya şifre!"
    return render_template('giris.html')


@app.route('/login/<isim>')
def login(isim):
    cursor = my_sql.cursor()
    cursor.execute("select * from apartman_sitesi.Kullanicilar where KullaniciAdi ='{}';".format(isim))
    sakin = cursor.fetchone()
    cursor1=my_sql.cursor()
    cursor1.execute("select DuyuruMetni from apartman_sitesi.Duyurular;")
    duyuru=cursor1.fetchone()
    cursor2=my_sql.cursor()
    cursor2.execute("select * from apartman_sitesi.Aidatlar where DaireNo= {}".format(sakin[6]))
    aidat=cursor2.fetchone()

    return render_template('ana_sayfa.html', soy=sakin[4], no=sakin[6],duyuru=duyuru[0],aidat=aidat)

@app.route("/yönetim", methods=['GET', 'POST'])
def yonetim():
    if request.method == 'POST':
        cursor = my_sql.cursor()
        isim = request.form['username']
        sifre = request.form['password']
        cursor.execute(
            "select apartman_sitesi.Yoneticiler.Sifre from apartman_sitesi.Yoneticiler where KullaniciAdi='{}';".format(isim))
        kullanıcı = cursor.fetchone()
        if sifre == kullanıcı[0]:
            return redirect(url_for('yonetim_ana', isim=isim))
        else:
            return "yanlış"
    return render_template('yonetici_giris.html')

@app.route("/yönetim_ana/<isim>")
def yonetim_ana(isim):
    cursor = my_sql.cursor()
    cursor.execute("select * from apartman_sitesi.Yoneticiler where KullaniciAdi='{}';".format(isim))
    sakin = cursor.fetchone()
    cursor1= my_sql.cursor()
    cursor1.execute("select DuyuruBasligi,DuyuruMetni from apartman_sitesi.Duyurular;")
    duyuru=cursor1.fetchone()
    bilgi="""
    select Kullanicilar.AdiSoyadi,Aidat.Tutar,Aidat.OdemeDurumu
    from apartman_sitesi.Kullanicilar
    inner join apartman_sitesi.Aidat on Aidat.DaireNo=Kullanicilar.DaireNo;
    """
    cursor2 = my_sql.cursor()
    cursor2.execute(bilgi)
    odeme=cursor2.fetchone()

    return render_template('yönetim_sayfa.html',isim=sakin[1],duyuru=duyuru,odeme=odeme)

################
@app.route('/kullanici_ekle', methods=['POST'])
def kullanici_ekle():
    if request.method == 'POST':
        cursor = my_sql.cursor()
        degerler = [request.form["username"],request.form["password"], request.form["user_type"],
            request.form["full_name"],request.form["email"], request.form["apartment"]]
        yeni_k = kisi(degerler[0], degerler[1], degerler[2], degerler[3], degerler[4], degerler[5])
        insert_query = "INSERT INTO kullanicilar (KullaniciAdi,Sifre,YetkiSeviyesi,AdiSoyadi,EpostaAdresi,DaireNo) VALUES (%s, %s, %s, %s, %s, %s)"
        data = (yeni_k.username, yeni_k.password, yeni_k.user_type, yeni_k.full_name, yeni_k.email, yeni_k.apartment)
        cursor.execute(insert_query, data)
        my_sql.commit()
        cursor.close()
        return "eklendi"

@app.route('/duyuru_ekle', methods=['POST'])
def duyuru_ekle():
    if request.method == 'POST':
        duyuru=[request.form["baslik"],request.form["icerik"]]
        yeni_duyuru="UPDATE apartman_sitesi.Duyurular SET DuyuruBasligi = '{}', DuyuruMetni = '{}' WHERE DuyuruID = 1;".format(duyuru[0],duyuru[1])
        cursor = my_sql.cursor()
        cursor.execute(yeni_duyuru)
        my_sql.commit()
        cursor.close()

        return "Duyuru eklendi!"
    else:
        return "Geçersiz istek methodu"

@app.route('/kullanici_sil', methods=['POST'])
def kullanici_sil():
    kullanici_ad = request.form["kullanici_ad"]
    if not kullanici_ad:
        return 'Kullanıcı adı eksik.', 400
    cursor = my_sql.cursor()
    try:
        cursor.execute("DELETE FROM kullanicilar WHERE KullaniciAdi = %s", (kullanici_ad,))
        my_sql.commit()
        return f'{kullanici_ad} adlı kullanıcı başarıyla silindi.'
    except mysql.connector.Error as err:
        return f'Hata: {err}', 500
    finally:
        cursor.close()


@app.route('/payment', methods=['POST'])
def payment():

    payment_info = request.get_json()

    aidat_tutari = 600.00
    payment_amount = payment_info.get('amount')
    if payment_amount == aidat_tutari:
        payment_status = 'success'
    else:

        payment_status = 'failure'
    return jsonify({'payment_status': payment_status})



if __name__ == '__main__':
    app.run(debug=True,port=5004)



