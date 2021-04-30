//
//  ImagenesCollectionViewController.swift
//  ProyectoNotasCoreData
//
//  Created by user on 15/4/21.
//

import UIKit
import CoreData


class ImagenesCollectionViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var imagenesNot = [Imagenes]()
    var notas  : Notas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Esto no funciona revisar
        //self.title = notas.titulo
        
        let buttonCamera = UIBarButtonItem(barButtonSystemItem: .camera, target: self, action: #selector(agregarFoto))
        navigationItem.rightBarButtonItem = buttonCamera
        mostrarImagenes()
    }


    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return imagenesNot.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! FotoCollectionViewCell
        let imagenNota = imagenesNot[indexPath.row]
        if let imagen = imagenNota.imagen {
            cell.foto.image = UIImage(data: imagen as Data)
        }
        return cell
    }
    
    @objc func agregarFoto(){
        let alerta = UIAlertController(title: "Hacer Foto", message: "Camara/Galeria", preferredStyle: .actionSheet)
        let camara = UIAlertAction(title: "Hacer Foto", style: .default) { (action) in
            self.hacerFotografia()
        }
        let galeria = UIAlertAction(title: "Entrar Galeria", style: .default) { (action) in
            self.entrarGaleria()
        }
        let cancelar = UIAlertAction(title: "cancelar", style: .default, handler: nil)
        alerta.addAction(camara)
        alerta.addAction(galeria)
        alerta.addAction(cancelar)
        present(alerta, animated: true, completion: nil)
    }
    func hacerFotografia(){
        let imagePiker = UIImagePickerController()
        imagePiker.delegate = self
        imagePiker.sourceType = .camera
        imagePiker.allowsEditing = true
        present(imagePiker, animated: true, completion: nil)
    }
    func entrarGaleria(){
        let imagePiker = UIImagePickerController()
        imagePiker.delegate = self
        imagePiker.sourceType = .camera
        imagePiker.allowsEditing = true
        imagePiker.modalPresentationStyle = .currentContext
        present(imagePiker, animated: true, completion: nil)
    }
    /*func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        <#code#>
    }*/
    //Que es lo que queremos que haga la galeria al cancelar la foto
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    func mostrarImagenes(){
        let contexto = Conexion().contexto()
        let fetchRequest : NSFetchRequest<Imagenes> = Imagenes.fetchRequest()
        let id = notas.id
        fetchRequest.predicate = NSPredicate(format: "id_notas == %@", id! as CVarArg)
        
        do {
            imagenesNot = try contexto.fetch(fetchRequest)
        } catch let error as NSError {
            print("error al cargar imagenes", error.localizedDescription)
        }
    }

}
