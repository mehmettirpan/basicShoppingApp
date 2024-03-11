//
//  DetailViewController.swift
//  ShoppingApp
//
//  Created by Mehmet Tırpan on 18.07.2023.
//

import UIKit
import CoreData
// hem picker ı oluşturmayı hem de kullanıcıyı başka bir işleme götürmeyi garanti altına almak için pickerContorller ve NavigationController ı ekledik.
class DetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var nameTextFiled: UITextField!
    
    @IBOutlet weak var sizeTextField: UITextField!
   
    @IBOutlet weak var priceTextField: UITextField!
    
    var chosenObjectName = ""
//    uuid yi option seçtik çünkü öbür taraftan atama yapsın biz buradan atama yapmayalaım
    var chosenObjectUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenObjectName != ""{
            
            
//            saveButton.isEnabled = false // böyle yaparsak eğer buton tıklanamaz hale gelir yani deactive buton şeklinde gri bir tonda gözükür
            
            saveButton.isHidden = true // böyle yaparsak eğer buton hiç gözükmez oluyor ama artı butonu içerisindeki kısım için de aynı kodu false yaptık çünkü daha sonra hata filan olursa o kısımdaki buton da gizli kalmamalı yoksa bu durumda da çalışıyor uygulama ve butonlar o sadece bu durumu garanti altına almak için yaptığımız bir işlemdir. ( 84.satırdaki işlem ya da else kısımındaki)
            
            
//            Core Data seçilen ürün bilgilerini göster
            
//            print(chosenObjectUUID) // seçilen ürünün UUID kısmını çıktı olarak xcode da verir
            if let uuidString = chosenObjectUUID?.uuidString{
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let contex = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
//                bu filtre mantıksal bazı sınır koyacaksınız ve arama buna göre yapılacak
//                id = %@ şuna eşit olanları getir demek
                fetchRequest.predicate = NSPredicate(format: "id = %@", uuidString)
                fetchRequest.returnsObjectsAsFaults = false
            
                do{
                    let results = try contex.fetch(fetchRequest)
                    
                    if results.count > 0 {
//                        diziye eklemeden sadece imageView textView ı filan yazdırmak için yaptık bu kısımı
                        for result in results as![NSManagedObject]{
                            if let name = result.value(forKey: "name") as? String{
                                nameTextFiled.text = name
                            }
                            
                            if let price = result.value(forKey: "price") as? Int{
                                priceTextField.text = String(price)
                            }
                            
                            if let size = result.value(forKey: "size") as? String{
                                sizeTextField.text = size
                            }
                            
                            if let imageData = result.value(forKey: "image") as? Data {
                                let image = UIImage(data: imageData) // görsel datayı buraya verdik ve bize şmageView oluşturdu
                                imageView.image = image
                            }
                        }
                    }
                    
                }catch{
                    printContent("you have to incorrect")
                }
                
                
            }
            
        } else{
            saveButton.isHidden = false
            saveButton.isEnabled = false // görsel seçmeden kaydet butonu aktif olmasın diye buraya bunu yaptık ve imagePickerController kısmına da true olanını yazacağız çünkü image seçildiğinde buton tekrardan aktif hale gelebilsin
            nameTextFiled.text = ""
            priceTextField.text = ""
            sizeTextField.text = ""
        }

//        view da herhangi bir yere tıklandığında klavyeyi aşağıya indirme komutu;
        
//        viewController da bir yere tıkladığımızı algılayan komut
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(keyboardOff))
        view.addGestureRecognizer(gestureRecognizer)
        
//        görsele dokunma işlevinin fonksiyonunu atadık
        
        imageView.isUserInteractionEnabled = true
        let imageGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(chooseImage))
        imageView.addGestureRecognizer(imageGestureRecognizer)
    }
    
//    görsel seçmek için dokunma işlevinin fonksiyon kodları
    @objc func chooseImage(){
        
//        galiye gidilecek galeriden fotoğraf seçilecek vs bir çok iş yapılacağı için pickerı delegete a bağladık.
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true)
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        as! ya da as? olana casting deniyor ve bu kodda any olan bir şeyi UIImage a çevirmek için casting kullanmamız gerekli. Soru işareti olan kesin olur ama ünlem olan force casting olduğu için hata almıyorsa o daha sağlıklı kullanılabilir bu durumlarda
        
        imageView.image = info[.editedImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true) //yeni oluşan imageViewController ı kapat demek
    }
    
    @objc func keyboardOff(){
        
        view.endEditing(true)
        
    }


    
    @IBAction func clickedSaveButton(_ sender: Any) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate //appDelegate a erişmek ve kullanabilmek için bu kodu yazdık
        let context = appDelegate.persistentContainer.viewContext
//        örneğin alışveriş listesi yapacağız ve bunu kaydedeceğiz ilk olarak bu nesneyi oluşturmamız lazım
        let shopping = NSEntityDescription.insertNewObject(forEntityName: "Shopping", into: context)
        // core data içerisindeki entity lere ulaşmak için kullandık
        
        shopping.setValue(nameTextFiled.text!, forKey: "name") // attribute deki değerlerin atamasını yapmak amacıyla bu kod dizinini yapıyoruz
        shopping.setValue(sizeTextField.text, forKey: "size")
        
        if let price = Int(priceTextField.text!){ //geçersiz değer girerse diye if let ile yaptık
            shopping.setValue(price, forKey: "price")
        }
        
//        universal unique id (UUID)
        shopping.setValue(UUID(), forKey: "id")
        
        let data = imageView.image!.jpegData(compressionQuality: 0.5)
        shopping.setValue(data, forKey: "image")
        
//        bu yaptıklarımızı kaydetmemiz gerekmekte şuan
        do{
            try context.save()
            print ("Data Saved Succesfully")
        } catch{
            print ("Data Error")
        }
        
        //yeni bir veri kaydettiğimi bildirip geri döndüğümüzde ekranı yenilenmesini sağladık. Haber göndermek için de notification center ı kullanabiliriz
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "inputtedData"), object: nil)
        
        self.navigationController?.popViewController(animated: true)// son oluşturduğumuz view controller ı stackten atıp bir önceki ekrana dönüş sağlıyor.
        
    }
    
}
