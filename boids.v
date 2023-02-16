//Detection d'attirance à l'autre coté

module main
import gg
import gx
import rand as rd
import math as m

const (
    win_width    = 600
    win_height   = 600
    bg_color     = gx.white
    nb_boids = 1000
    boid_size = 3
    speed = 2
    detect_radius = 30
    pow_detec_radius = detect_radius*detect_radius
    pow_trop_pres = 28
)

[heap]
struct Boid{
    mut:
    x int
    y int
    dir_x f64
    dir_y f64
    delta_dir_x f64
    delta_dir_y f64
}


struct App {
mut:
    gg    &gg.Context = unsafe { nil }
	boids []Boid
    opti_list [][][]&Boid = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
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
        sample_count: 2
    )
    for _ in 0..nb_boids{
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
        for l in -1..2{
            for c in -1..2{
                if i + l >= 0 && i + l < win_width/detect_radius && j + c >= 0 && j + c < win_height/detect_radius{
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
                }else if i + l < 0{
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
                    }else if j+c >win_height/detect_radius{
                        /*for other in app.opti_list[i+l+win_height/detect_radius][j+c-win_width/detect_radius]{
                            dist := m.pow(m.abs(boid.x - other.x + win_width),2)+m.pow(m.abs(boid.y - other.y + win_height),2)
                            if dist < pow_detec_radius{
                                mut new_crea := other
                                new_crea.x -= win_width
                                new_crea.y -= win_height
                                if dist < pow_trop_pres{
                                    boids_trop << new_crea // a modifier
                                }else{
                                    boids_normal << new_crea// a modifier
                                }
                            }
                        }*/
                    }else{

                    }
                }else if i+l > win_width/detect_radius{
                    if j+c < 0{

                    }else if j+c >win_height/detect_radius{
                        
                    }else{

                    }
                }
            }
        }
        nb_near := boids_trop.len + boids_normal.len
        // COHESION
        mut moy_coord_x := 0.0
        mut moy_coord_y := 0.0
        // SEPARATION
        mut moy_separation_x := 0.0
        mut moy_separation_y := 0.0
        //ALIGNEMENT
        mut moy_alignement_x := 0.0
        mut moy_alignement_y := 0.0
        for other in boids_trop{
            moy_coord_x += other.x
            moy_coord_y += other.y
            moy_separation_x += boid.x - other.x
            moy_separation_y += boid.y - other.y
            moy_alignement_x += other.dir_x
            moy_alignement_y += other.dir_y
        }
        for other in boids_normal{
            moy_coord_x += other.x
            moy_coord_y += other.y
            moy_alignement_x += other.dir_x
            moy_alignement_y += other.dir_y
        }
        moy_coord_x /= nb_near
        moy_coord_y /= nb_near
        boid.dir_x += int((moy_coord_x - boid.x)*0.5)
        boid.dir_y += int((moy_coord_y - boid.y)*0.5)
        // SEPARATION
        boid.x += int(moy_separation_x * 0.6)
        boid.y += int(moy_separation_y * 0.6)
        //ALIGNEMENT
        boid.dir_x += int(moy_alignement_x * 0.5)
        boid.dir_y += int(moy_alignement_y * 0.5)

        //Apply change
        boid.dir_x += boid.delta_dir_x*0.1
        boid.dir_y += boid.delta_dir_y*0.1

        //Apply vector
        mut prop_coef := m.sqrt(m.pow(boid.dir_x, 2)+m.pow(boid.dir_y, 2)) / speed
        if prop_coef > 0{
            boid.dir_x /= prop_coef*0.9
            boid.dir_y /= prop_coef*0.9
            boid.x += int(boid.dir_x)
            boid.y += int(boid.dir_y)
        }
        boid.dir_x *= 0.25
        boid.dir_y *= 0.25
        boid.delta_dir_x = 0.0
        boid.delta_dir_y = 0.0

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
        
        app.gg.draw_circle_filled(boid.x, boid.y, boid_size, gx.Color{red_color, 0, blue_color, 255})
    }
    app.gg.end()
    app.opti_list = [][][]&Boid{len:win_width/detect_radius, init:[][]&Boid{len:win_height/detect_radius, init:[]&Boid{cap:10}}}
}