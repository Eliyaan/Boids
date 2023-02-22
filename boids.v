module main
import gg
import gx
import rand as rd
import math as m

const (
    win_width    = 640  //  /!\ the size must be un multiple du radius de détection
    win_height   = 640
    bg_color     = gx.white
    detect_radius = 20
    pow_detec_radius = detect_radius*detect_radius
    pow_trop_pres = 12
)

[heap]
struct Boid{
    mut:
    x f64
    y f64
    dir_x f64
    dir_y f64
    delta_dir_x f64
    delta_dir_y f64
}

[heap]
struct App {
mut:
    gg    &gg.Context = unsafe { nil }
	boids []Boid
    opti_list [][][]&Boid = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
    text_cfg gx.TextCfg
    nb_boids int = 1000
    boid_size int = 2
    speed f64 = 0.003
    cohesion f64 = 1.0
    separation f64 = 40.0
    alignement f64 = 0.1
    friction_reduc f64 = 0.9
    max_crea_trop_proche int = 20
}



fn main() {
    mut app := &App{
        gg: 0
    }
    app.gg = gg.new_context(
        width: win_width
        height: win_height
        create_window: true
        window_title: '- Boids -'
        user_data: app
        bg_color: bg_color
        frame_fn: on_frame
        sample_count: 6
        fullscreen: true
        event_fn: on_event
    )
    app.text_cfg = gx.TextCfg{color: gx.white, size: 20, align: .left, vertical_align: .top}
    for _ in 0..app.nb_boids{
        app.boids << Boid{rd.int_in_range(0, win_width)!, rd.int_in_range(0, win_height)!, rd.f64_in_range(-1.0, 1.0)!, rd.f64_in_range(-1.0, 1.0)!, 0.0, 0.0}
    }
    //lancement du programme/de la fenêtre
    app.gg.run()
}


fn (mut app App) store_boids_opti_grid(){
    for mut boid in app.boids{
        //store to the right list
        for boid.x >= win_width{
            boid.x -= win_width
        }
        for boid.x < 0{
            boid.x += win_width
        }
        for boid.y >= win_height{
            boid.y -= win_height
        }
        for boid.y < 0{
            boid.y += win_height
        }
        i := int(boid.x/detect_radius)
        j := int(boid.y/detect_radius)
        app.opti_list[i][j] << &boid
    }
}


fn on_frame(mut app App) {
    //Draw
    app.store_boids_opti_grid()
    app.gg.begin()
    for mut boid in app.boids{
        mut boids_trop := []Boid{}
        mut boids_normal := []Boid{}
        i := int(boid.x/detect_radius)
        j := int(boid.y/detect_radius)
        if app.opti_list[i][j].len < f64(app.max_crea_trop_proche)*1.5{
            for l in -1..2{
                for c in -1..2{
                    if i + l < 0{
                        if j+c < 0{
                            for other in app.opti_list[i+l+win_height/detect_radius][j+c+win_width/detect_radius]{
                                dist := m.pow(m.abs(boid.x - (other.x - win_width)),2)+m.pow(m.abs(boid.y - (other.y - win_height)),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x-win_width, other.y-win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }else if j+c >= win_height/detect_radius{
                            for other in app.opti_list[i+l+win_height/detect_radius][j+c-win_width/detect_radius]{
                                dist := m.pow(m.abs(boid.x - (other.x + win_width)),2)+m.pow(m.abs(boid.y - (other.y - win_height)),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x+win_width, other.y-win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }else{
                            for other in app.opti_list[i+l+win_height/detect_radius][j+c]{
                                dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - (other.y - win_height) ),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x, other.y-win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }
                    }else if i+l >= win_width/detect_radius{
                        if j+c < 0{
                            for other in app.opti_list[i+l-win_height/detect_radius][j+c+win_width/detect_radius]{
                                dist := m.pow(m.abs(boid.x - (other.x - win_width)),2)+m.pow(m.abs(boid.y - (other.y + win_height)),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x-win_width, other.y+win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }else if j+c >= win_height/detect_radius{
                            for other in app.opti_list[i+l-win_height/detect_radius][j+c-win_width/detect_radius]{
                                dist := m.pow(m.abs(boid.x - (other.x + win_width)),2)+m.pow(m.abs(boid.y - (other.y + win_height)),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x+win_width, other.y+win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }else{
                            for other in app.opti_list[i+l-win_height/detect_radius][j+c]{
                                dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - (other.y + win_height)),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x, other.y+win_height, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }
                    }else{
                        if j+c < 0{
                            for other in app.opti_list[i+l][j+c+win_width/detect_radius]{
                                dist := m.pow(m.abs(boid.x - (other.x-win_width)),2)+m.pow(m.abs(boid.y - other.y),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x-win_width, other.y, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }else if j+c >= win_height/detect_radius{
                            for other in app.opti_list[i+l][j+c-win_width/detect_radius]{
                                dist := m.pow(m.abs(boid.x - (other.x+win_width)),2)+m.pow(m.abs(boid.y - other.y),2)
                                if dist < pow_detec_radius{
                                    new_crea := Boid{other.x+win_width, other.y, other.dir_x, other.dir_y, other.delta_dir_x, other.delta_dir_y}
                                    if dist < pow_trop_pres{
                                        boids_trop << new_crea 
                                    }else{
                                        boids_normal << new_crea
                                    }
                                }
                            }
                        }else{
                            for other in app.opti_list[i+l][j+c]{
                                dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - other.y),2)
                                if dist < pow_detec_radius{
                                    if dist < pow_trop_pres{
                                        boids_trop << other
                                    }else{
                                        boids_normal << other
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }else{
            for other in app.opti_list[i][j]{
                dist := m.pow(m.abs(boid.x - other.x),2)+m.pow(m.abs(boid.y - other.y),2)
                if dist < pow_detec_radius{
                    if dist < pow_trop_pres{
                        boids_trop << other
                    }else{
                        boids_normal << other
                    }
                }
            }
        }
        nb_near := boids_trop.len + boids_normal.len

        mut posi_cible_cohesion_x := 0.0
        mut posi_cible_cohesion_y := 0.0
        mut average_dir_x := 0.0
        mut average_dir_y := 0.0
        mut delta_repoussage_x := 0.0
        mut delta_repoussage_y := 0.0
        if boids_trop.len > app.max_crea_trop_proche{
            mut index := 0
            for _ in 0..app.max_crea_trop_proche{
                index = rd.int_in_range(0, boids_trop.len)or {panic(err)}
                posi_cible_cohesion_x += boids_trop[index].x
                posi_cible_cohesion_y += boids_trop[index].y
                delta_repoussage_x += boids_trop[index].x
                delta_repoussage_y += boids_trop[index].y
                average_dir_x += boids_trop[index].dir_x
                average_dir_y += boids_trop[index].dir_y
                boids_trop.delete(index)
            }
            posi_cible_cohesion_x /= app.max_crea_trop_proche
            posi_cible_cohesion_y /= app.max_crea_trop_proche
            delta_repoussage_x /= app.max_crea_trop_proche
            delta_repoussage_y /= app.max_crea_trop_proche
            average_dir_x /= app.max_crea_trop_proche
            average_dir_y /= app.max_crea_trop_proche
            delta_repoussage_x = boid.x - delta_repoussage_x
            delta_repoussage_y = boid.y - delta_repoussage_y
            posi_cible_cohesion_x -= boid.x
            posi_cible_cohesion_y -= boid.y
        }else{
            for other in boids_trop{
                posi_cible_cohesion_x += other.x
                posi_cible_cohesion_y += other.y
                delta_repoussage_x += other.x
                delta_repoussage_y += other.y
                average_dir_x += other.dir_x
                average_dir_y += other.dir_y
            }
            for other in boids_normal{
                posi_cible_cohesion_x += other.x
                posi_cible_cohesion_y += other.y
                average_dir_x += other.dir_x
                average_dir_y += other.dir_y
            }        
            posi_cible_cohesion_x /= nb_near
            posi_cible_cohesion_y /= nb_near
            delta_repoussage_x /= boids_trop.len
            delta_repoussage_y /= boids_trop.len
            average_dir_x /= nb_near
            average_dir_y /= nb_near
            delta_repoussage_x = boid.x - delta_repoussage_x
            delta_repoussage_y = boid.y - delta_repoussage_y
            posi_cible_cohesion_x -= boid.x
            posi_cible_cohesion_y -= boid.y
        }

        boid.dir_x += average_dir_x*app.alignement + posi_cible_cohesion_x*app.cohesion + delta_repoussage_x*app.separation
        boid.dir_y += average_dir_y*app.alignement + posi_cible_cohesion_y*app.cohesion + delta_repoussage_y*app.separation
        boid.x += boid.dir_x*app.speed
        boid.y += boid.dir_y*app.speed

        boid.dir_x *= app.friction_reduc
        boid.dir_y *= app.friction_reduc


        //draw
        mut red_color := u8(0)
        if nb_near*6 > 255{
            red_color = 255
        }else{
            red_color += u8(nb_near*6)
        }
        mut blue_color := u8(0)
        if boids_trop.len*20 > 255{
            blue_color = 255
        }else{
            blue_color += u8(boids_trop.len*20)
        }
        
        app.gg.draw_circle_filled(f32(boid.x +50), f32(boid.y+60), app.boid_size, gx.Color{red_color, 0, blue_color, 255})
    }
    
    //UI
    app.gg.draw_rect_filled(800, 0, 800, 1300, gx.Color{r: 255, g: 200, b: 200})
    app.gg.draw_text(1038, 7, "  -    +", app.text_cfg)
    app.gg.draw_text(840, 25, "Nb of boids: ${app.nb_boids}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 26, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 26, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus

    app.gg.draw_text(840, 55, "Boids' size: ${app.boid_size}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 56, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 56, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus
    
    app.gg.draw_text(840, 85, "Boids' speed: ${app.speed}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 86, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 86, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus

    app.gg.draw_text(840, 115, "Cohesion factor: ${app.cohesion}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 116, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 116, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus

    app.gg.draw_text(840, 145, "Separation factor: ${app.separation}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 146, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 146, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus

    app.gg.draw_text(840, 175, "Alignement factor: ${app.alignement}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 176, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 176, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus

    app.gg.draw_text(840, 205, "Friction: ${app.friction_reduc}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 206, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 206, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus
    
    app.gg.draw_text(840, 235, "Boids calculated: ${app.max_crea_trop_proche}", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 236, 20, 20, 4,  gx.Color{r: 230, g: 200, b: 255}) // minus
    app.gg.draw_rounded_rect_filled(1070, 236, 20, 20, 4,  gx.Color{r: 255, g: 160, b: 255}) // plus

    app.gg.draw_text(840, 265, "Reset: ", app.text_cfg)
    app.gg.draw_rounded_rect_filled(1040, 266, 20, 20, 4, gx.Color{255,182,193,255}) 


    app.gg.end()
    app.opti_list = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
}




fn on_event(e &gg.Event, mut app App){
    match e.typ {
        .key_down {
            match e.key_code {
                .escape {app.gg.quit()}
                else {}
            }
        }
        .mouse_up {
            match e.mouse_button{
                .left{app.check_buttons(e.mouse_x, e.mouse_y) or {panic("check button error")}}
                else{}
        }}
        else {}
    }

}

fn (mut app App) check_buttons(mouse_x f64, mouse_y f64)!{//a opti
    if mouse_x > 1040 && mouse_x < 1090{
        if mouse_x < 1060{
            match true{
                (mouse_y > 26 && mouse_y < 46){
                        app.nb_boids -= 100
                        app.boids = []
                        for _ in 0..app.nb_boids{
                            app.boids << Boid{rd.int_in_range(0, win_width)!, rd.int_in_range(0, win_height)!, rd.f64_in_range(-1.0, 1.0)!, rd.f64_in_range(-1.0, 1.0)!, 0.0, 0.0}
                        }
                    }
                (mouse_y > 56 && mouse_y < 76){app.boid_size -= 1}
                (mouse_y > 86 && mouse_y < 106){
                        app.speed -= 0.0001
                        app.speed = m.round_sig(app.speed, 4)
                    }
                (mouse_y > 116 && mouse_y < 136){app.cohesion -= 0.05
                        app.cohesion = m.round_sig(app.cohesion, 2)
                    }
                (mouse_y > 146 && mouse_y < 166){app.separation -= 0.2
                        app.separation = m.round_sig(app.separation, 1)
                    }
                (mouse_y > 176 && mouse_y < 196){app.alignement -= 0.05
                        app.alignement = m.round_sig(app.alignement, 2)
                    }
                (mouse_y > 206 && mouse_y < 226){app.friction_reduc -= 0.05
                        app.friction_reduc = m.round_sig(app.friction_reduc, 2)
                    }
                (mouse_y > 236 && mouse_y < 256){app.max_crea_trop_proche -= 1}
                (mouse_y > 266 && mouse_y < 286){
                        app.boids = []
                        for _ in 0..app.nb_boids{
                            app.boids << Boid{rd.int_in_range(0, win_width)!, rd.int_in_range(0, win_height)!, rd.f64_in_range(-1.0, 1.0)!, rd.f64_in_range(-1.0, 1.0)!, 0.0, 0.0}
                        }
                    }
                else{}
            }
        }else if mouse_x > 1070{
            match true{
                (mouse_y > 26 && mouse_y < 46){
                        app.nb_boids += 100
                        app.boids = []
                        for _ in 0..app.nb_boids{
                            app.boids << Boid{rd.int_in_range(0, win_width)!, rd.int_in_range(0, win_height)!, rd.f64_in_range(-1.0, 1.0)!, rd.f64_in_range(-1.0, 1.0)!, 0.0, 0.0}
                        }
                    }
                (mouse_y > 56 && mouse_y < 76){app.boid_size += 1}
                (mouse_y > 86 && mouse_y < 106){
                        app.speed += 0.0001
                        app.speed = m.round_sig(app.speed, 4)
                    }
                (mouse_y > 116 && mouse_y < 136){app.cohesion += 0.05
                        app.cohesion = m.round_sig(app.cohesion, 2)
                    }
                (mouse_y > 146 && mouse_y < 166){app.separation += 0.2
                        app.separation = m.round_sig(app.separation, 1)
                    }
                (mouse_y > 176 && mouse_y < 196){app.alignement += 0.05
                        app.alignement = m.round_sig(app.alignement, 2)
                    }
                (mouse_y > 206 && mouse_y < 226){app.friction_reduc += 0.05
                        app.friction_reduc = m.round_sig(app.friction_reduc, 2)
                    }
                (mouse_y > 236 && mouse_y < 256){app.max_crea_trop_proche += 1}
                else{}
            }
        }
    }
}
