//
//  ViewController.swift
//  ShoppingApp
//
//  Created by Mehmet Tırpan on 18.07.2023.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    var nameArray = [String]()
    var idArray = [UUID]()
    
    var chosenName = ""
    var chosenUUID : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //        üst kısımda yer alan artı yani içerik ekleme butonunu ekleme işlemi
        
        
        //        targette selfi seçtik o bu view controllerde kal demek
        
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(clickedAddButton))
        navigationController?.navigationBar.topItem?.rightBarButtonItems = [addButton]
        
        
        /*
         ** kod değiştir biraz ama mantık yakın **
         eşittir kısmına kadar butonun konumunu ayarladık ve eşittirden sonra UIBarButtonItem yani bar butonu için özel olan buton kodunu aktif edip daha sonra systemItem ı seçip ikonu sistem ikonlarından seçecek şekilde buton tasarladık mesela biz .add kullanarak + olan butonu kullandık
         */
        getData()
        
    }
    
    
//    görünüm gösterilmeden önce çağırılır
    override func viewWillAppear(_ animated: Bool) {
//        .addObserved dedik yani gözlemci ekledik buraya
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name(rawValue: "inputtedData"), object: nil)
    }
    
    
    //    verileri çekme fonksiyonu
    
    @objc func getData(){
        
//        başlamadan önce diziyi sıfırladık yoksa bütün diziden bir daha kaydediyor
        
        nameArray.removeAll(keepingCapacity: false)
        idArray.removeAll(keepingCapacity: false)
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        //        çekme isteği oluşturduk fetchRequest ilee
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
        fetchRequest.returnsObjectsAsFaults = false
        
        do{
            let results = try context.fetch(fetchRequest)
            if results.count > 0{
                for result in results as! [NSManagedObject]{
                    if let name = result.value(forKey: "name") as? String{
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID{
                        idArray.append(id)
                    }
                    
                }
                // table view a datalar değişti güncelle anlamında bu kodu kullandık
                tableView.reloadData()
              }
            } catch{
                print ("Fetch Error")
                
            }
        
        
    }
    
    
    @objc func clickedAddButton(){
        chosenName = ""
//        diğer tarafa giderken boş bir string olarak gidecektir ve diğer taraf bunun boşlıktan geldiğini anlayacaktır. diğer taraf ise if chosenObjectName else kısmı
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC"{
            let destinationVC = segue.destination as! DetailViewController
            destinationVC.chosenObjectName = chosenName
            destinationVC.chosenObjectUUID = chosenUUID
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenName = nameArray[indexPath.row]
        chosenUUID = idArray[indexPath.row]
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    
    
//    verileri yalnzıca table view dan değil veri tabanından da silmek için bunu kullanıyoruz.
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            // silmek için önce ilgili veriyi tabandan çekmemiz gerek
            
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Shopping")
            let uuidString = idArray[indexPath.row].uuidString
            
            fetchRequest.predicate = NSPredicate(format: "id=%@", uuidString)
            fetchRequest.returnsObjectsAsFaults = false
            
            do{
                let results = try context.fetch(fetchRequest)
                if results.count > 0{
                    for result in results as! [NSManagedObject]{
//                        bu gelen sonuç hangi tekli uuid yi çektiysek onu çağıran sonuç ama yine de if let yaparak kontrol edebiliriz aşağıdaki örnek gibi
                        if let id = result.value(forKey: "id") as? UUID{
                            if id == idArray[indexPath.row]{ // bu olmadan da olur ama bunlar garantiye almak açamlı yapılan işlemler ya da aşağıdaki break olmasa da olur ama işlemi sağlamak almak gerekiyor.
                                context.delete(result)
                                nameArray.remove(at: indexPath.row)
                                idArray.remove(at: indexPath.row)
//                                veriler değişti kendini güncelle demek tableview için
                                self.tableView.reloadData()
                                do{
                                    
                                    try context.save()
                                }
                                catch{
                                    
                                }
                                break
                            }
                        }
                            
                    }
                }
                
                
            }catch{
                print("Error editing Style")
            }
            
        }
    }
    

}


